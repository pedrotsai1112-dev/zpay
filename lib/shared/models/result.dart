/// 通用結果類型，用於處理可能失敗的操作
class Result<T> {
  final T? _data;
  final String? _error;

  const Result._(this._data, this._error);

  /// 創建成功結果
  factory Result.success(T data) => Result._(data, null);

  /// 創建失敗結果
  factory Result.failure(String error) => Result._(null, error);

  /// 是否成功
  bool get isSuccess => _error == null;

  /// 是否失敗
  bool get isFailure => _error != null;

  /// 獲取數據（僅在成功時可用）
  T? get data => _data;

  /// 獲取錯誤信息（僅在失敗時可用）
  String? get error => _error;

  /// 映射數據
  Result<U> map<U>(U Function(T data) mapper) {
    if (isSuccess && _data != null) {
      try {
        return Result.success(mapper(_data as T));
      } catch (e) {
        return Result.failure(e.toString());
      }
    }
    return Result.failure(_error ?? 'Unknown error');
  }

  /// 映射錯誤
  Result<T> mapError(String Function(String error) mapper) {
    if (isFailure) {
      return Result.failure(mapper(_error!));
    }
    return this;
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'Result.success($_data)';
    } else {
      return 'Result.failure($_error)';
    }
  }
}

/// 擴展方法，讓 Future\<Result\<T\>\> 更易使用
extension FutureResultExtension<T> on Future<Result<T>> {
  /// 異步映射數據
  Future<Result<U>> mapAsync<U>(Future<U> Function(T data) mapper) async {
    final result = await this;
    if (result.isSuccess && result.data != null) {
      try {
        final mapped = await mapper(result.data as T);
        return Result.success(mapped);
      } catch (e) {
        return Result.failure(e.toString());
      }
    }
    return Result.failure(result.error ?? 'Unknown error');
  }
}

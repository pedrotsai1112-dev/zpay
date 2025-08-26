#!/bin/bash

# ZPay TDD 工作流程腳本
# 使用方法: ./scripts/tdd_workflow.sh [test_file_path]

set -e

echo "🔴 ZPay TDD 工作流程開始"
echo "=================================="

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 檢查參數
if [ $# -eq 0 ]; then
    echo -e "${YELLOW}運行所有測試${NC}"
    TEST_TARGET="."
else
    echo -e "${YELLOW}運行指定測試: $1${NC}"
    TEST_TARGET="$1"
fi

# 步驟 1: 確保現有測試通過
echo -e "\n${BLUE}步驟 1: 檢查現有測試狀態${NC}"
echo "運行: flutter test"
if flutter test "$TEST_TARGET"; then
    echo -e "${GREEN}✅ 現有測試全部通過${NC}"
else
    echo -e "${RED}❌ 現有測試失敗！請先修復現有測試${NC}"
    exit 1
fi

# 步驟 2: 代碼分析
echo -e "\n${BLUE}步驟 2: 代碼質量檢查${NC}"
echo "運行: flutter analyze"
if flutter analyze; then
    echo -e "${GREEN}✅ 代碼分析通過${NC}"
else
    echo -e "${RED}❌ 代碼分析發現問題！請修復後再繼續${NC}"
    exit 1
fi

# 步驟 3: 生成測試覆蓋率報告
echo -e "\n${BLUE}步驟 3: 生成測試覆蓋率報告${NC}"
echo "運行: flutter test --coverage"
if flutter test --coverage "$TEST_TARGET"; then
    echo -e "${GREEN}✅ 測試覆蓋率報告已生成${NC}"
    
    # 如果有 lcov 工具，顯示覆蓋率摘要
    if command -v lcov &> /dev/null; then
        echo -e "\n${BLUE}測試覆蓋率摘要:${NC}"
        lcov --summary coverage/lcov.info
    fi
else
    echo -e "${YELLOW}⚠️  無法生成覆蓋率報告，但測試通過${NC}"
fi

# 步驟 4: TDD 提醒
echo -e "\n${YELLOW}🔄 TDD 循環提醒:${NC}"
echo "1. 🔴 RED: 寫一個會失敗的測試"
echo "2. 🟢 GREEN: 寫最少代碼讓測試通過"
echo "3. 🔵 REFACTOR: 重構代碼保持測試通過"
echo ""
echo -e "${GREEN}✅ TDD 工作流程檢查完成！${NC}"
echo -e "${BLUE}準備開始你的下一個 RED-GREEN-REFACTOR 循環${NC}"

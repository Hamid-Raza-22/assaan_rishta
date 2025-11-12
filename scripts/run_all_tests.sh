#!/bin/bash
# Assaan Rishta - Complete Test Runner Script
# Run sab tests aur coverage report generate karo

echo "========================================"
echo "Assaan Rishta - Running All Tests"
echo "========================================"
echo ""

echo "[1/4] Installing dependencies..."
flutter pub get
echo ""

echo "[2/4] Running Unit Tests..."
flutter test test/unit/ --reporter expanded
echo ""

echo "[3/4] Running Widget Tests..."
flutter test test/widget/ --reporter expanded
echo ""

echo "[4/4] Running Integration Tests..."
flutter test integration_test/ --reporter expanded
echo ""

echo "========================================"
echo "Generating Coverage Report..."
echo "========================================"
flutter test --coverage
echo ""

echo "========================================"
echo "Tests Complete!"
echo "========================================"
echo ""
echo "Coverage report: coverage/lcov.info"
echo ""

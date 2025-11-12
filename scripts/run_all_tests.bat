@echo off
REM Assaan Rishta - Complete Test Runner Script
REM Run sab tests aur coverage report generate karo

echo ========================================
echo Assaan Rishta - Running All Tests
echo ========================================
echo.

echo [1/4] Installing dependencies...
call flutter pub get
echo.

echo [2/4] Running Unit Tests...
call flutter test test/unit/ --reporter expanded
echo.

echo [3/4] Running Widget Tests...
call flutter test test/widget/ --reporter expanded
echo.

echo [4/4] Running Integration Tests...
call flutter test integration_test/ --reporter expanded
echo.

echo ========================================
echo Generating Coverage Report...
echo ========================================
call flutter test --coverage
echo.

echo ========================================
echo Tests Complete!
echo ========================================
echo.
echo Coverage report: coverage/lcov.info
echo.

pause

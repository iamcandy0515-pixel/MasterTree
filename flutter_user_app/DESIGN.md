# Flutter User App Design Document

This document outlines the UI/UX design specifications and implementation details for the Flutter User App.

## 1. Quiz Screen Redesign (2026-02-08)

Changes made to improve usability and visual appeal for the tree identification quiz.

### 1.1 Layout Specifications

- **Main Image**:
    - **Size**: Fixed at `400x400` logical pixels.
    - **Style**: Rounded corners (`16px`), shadow for depth.
    - **Content**: Displays the primary identification feature of the tree.

- **Header**:
    - **Components**: Back button (`arrow_back_ios`), Title ('수목 식별 학습'), Progress Indicator.
    - **Style**: Dark translucent background (`AppColors.backgroundDark.withOpacity(0.8)`).
    - **Progress**: Linear bar showing current question status (e.g., 3/10).

- **Hint Section**:
    - **Components**: 'Hint View' text label, Horizontal scroll view of hint categories.
    - **Categories**: 'Leaf', 'Bark', 'Flower', 'Fruit', 'Winter Bud', 'Representative' (6 total).
    - **Interaction**: Tapping a category shows a floating hint message.
    - **Button Placement**:
        - **Retry Button**: Placed immediately to the right of the 'Hint View' label. Visible only on wrong answer.
        - **Next Question Button**: Placed to the right of the hint categories row. Always visible after an answer is attempted.

### 1.2 Button Specifications

- **Next Question Button**:
    - **Style**: Text button with transparent background.
    - **Content**: Text '다음 문제' + Right Arrow Icon (`arrow_forward_ios`).
    - **Color**: Primary Color (`AppColors.primary`, Acid Lime).
    - **Visibility**: Appears immediately after an answer is selected (Correct or Incorrect).

- **Retry Button**:
    - **Style**: Small text button with refresh icon.
    - **Content**: Icon (`refresh`) + Text '다시 풀기'.
    - **Color**: Red Accent (`Colors.redAccent`).
    - **Visibility**: Appears only when an **incorrect** answer is selected.

### 1.3 Interaction Flow

1.  **Initial State**:
    - Image displayed.
    - Options (1, 2, 3) available for selection.
    - No buttons visible in hint section.

2.  **Correct Answer Selected**:
    - **Option Feedback**: Option background turns `AppColors.primary` (Acid Lime). Icon changes to checkmark.
    - **Feedback**: Floating Description appears with detailed tree info (auto-hides in 5s).
    - **Action**: 'Next Question' button appears next to hint categories.

3.  **Incorrect Answer Selected**:
    - **Option Feedback**: Option background turns `Colors.red` (Red). Icon changes to 'X'.
    - **Action**:
        - 'Next Question' button appears (allows skipping).
        - 'Retry' button appears next to 'Hint View' label (allows re-attempt).

### 1.4 Visual Style Guide

- **Colors**:
    - **Background**: `AppColors.backgroundDark` (Dark Grey/Black).
    - **Primary (Success)**: `AppColors.primary` (Acid Lime) - Used for correct answers, active hints, next button.
    - **Error (Wrong)**: `Colors.redAccent` - Used for wrong answers, retry button.
    - **Text**: White for primary content, Muted Grey for labels.

- **Typography**:
    - **Labels**: Bold, readable fonts.
    - **Hint Text**: Small, auxiliary text.

- **Animations**:
    - **Floating Box**: Scale and Fade transition (300ms/400ms).
    - **Button Appearance**: Immediate (conditional rendering).

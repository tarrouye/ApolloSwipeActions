/*

 SwipeActions.swift
 ApolloSwipeActions

 Created by Theo Arrouye on 6/10/25.
 Copyright © 2025 Theo Arrouye. All rights reserved.

 MIT License

 Copyright (c) 2025 Theo Arrouye

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import SwiftUI

// MARK: - SwipeAction Model
public struct ApolloSwipeAction {
  let color: Color
  var foregroundColor: Color = .white
  let icon: String
  var font: Font = .title
  let action: () -> Void
}

// MARK: - Swipe Gesture Modifier
public struct ApolloSwipeActionsModifier: ViewModifier {
  private static let selectionFeedbackGenerator = UISelectionFeedbackGenerator()

  public let leadingAction: ApolloSwipeAction?
  public let trailingAction: ApolloSwipeAction?
  public let minDragDistance: CGFloat
  public let triggerDistance: CGFloat
  public let iconFrameWidth: CGFloat
  /// Whether or not you can continue to drag on the other side
  /// after having started a drag on one side
  public let allowsContinuousDrag: Bool
  public let actionSpacing: CGFloat
  public let actionCornerRadius: CGFloat

  @State private var offset: CGFloat = 0
  @State private var isTriggered: Bool = false
  @State private var isBouncingIcon: Bool = false

  @State private var lockedDirection: Int = 0

  @GestureState private var isCurrentlyDragging: Bool = false

  func body(content: Content) -> some View {
      content
        .offset(x: offset)
        .contentShape(.rect)
        .simultaneousGesture(
          DragGesture(minimumDistance: minDragDistance)
            .updating($isCurrentlyDragging) { value, state, _ in
              // Only start dragging if the gesture moves more horizontally than vertically
              // This allows vertical scrolling to work normally
              if abs(value.translation.width) > abs(value.translation.height) && abs(value.translation.width) > minDragDistance {
                state = true
              }
            }
            .onChanged { value in
              
              let translation = value.translation.width

              // Only allow swipe if we have an action for that direction
              if translation > 0 && leadingAction != nil {
                offset = min(lockedDirection == -1 ? 0 : translation, translation)
              } else if translation < 0 && trailingAction != nil {
                offset = max(lockedDirection == 1 ? 0 : translation, translation)
              } else if translation == 0 {
                offset = 0
              }

              if !allowsContinuousDrag, lockedDirection == 0 {
                lockedDirection = Int(offset/abs(translation))
              }

              // Update triggered state based on swipe distance
              let wasTriggered = isTriggered
              isTriggered = abs(offset) > triggerDistance
              if isTriggered, !wasTriggered {
                Self.selectionFeedbackGenerator.selectionChanged()
                
                withAnimation(.easeIn(duration: 0.15)) {
                  isBouncingIcon = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                  withAnimation(.easeOut(duration: 0.15)) {
                    isBouncingIcon = false
                  }
                }
              }
            }
            .onEnded { value in
              let shouldTrigger = abs(offset) > triggerDistance

              if shouldTrigger {
                // Trigger appropriate action
                if offset > 0 {
                  leadingAction?.action()
                } else {
                  trailingAction?.action()
                }
              }

              // Reset state
              withAnimation(.spring(duration: 0.3)) {
                offset = 0
              }
              lockedDirection = 0
              isTriggered = false
            }
        )
        .background {
          let fullPeek = min(50, triggerDistance)
          let peekScale = min(1, abs(offset) / fullPeek)
          ZStack {
            // Leading action
            if let leadingAction {
              leadingAction.color
                .clipShape(.rect(cornerRadius: actionCornerRadius))
                .padding(.trailing, actionSpacing)
                .frame(width: max(0, offset))
                .overlay(alignment: .leading) {
                  actionIcon(leadingAction)
                    .opacity(peekScale)
                    .offset(x: min(0, offset - iconFrameWidth))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Trailing action
            if let trailingAction = trailingAction {
              trailingAction.color
                .clipShape(.rect(cornerRadius: actionCornerRadius))
                .padding(.leading, actionSpacing)
                .frame(width: max(0, -offset))
                .overlay(alignment: .trailing) {
                  actionIcon(trailingAction)
                    .opacity(peekScale)
                    .offset(x: max(0, offset + iconFrameWidth))
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
          }
        }
  }

  private func actionIcon(_ action: ApolloSwipeAction) -> some View {
    Image(systemName: action.icon)
      .font(isTriggered ? action.font.bold() : action.font)
      .foregroundStyle(action.foregroundColor)
      .scaleEffect(isBouncingIcon ? 1.1 : 1)
      .frame(width: iconFrameWidth, alignment: .center)
  }
}

// MARK: - View Extension
public extension View {
  func apolloSwipeActions(
    leading: ApolloSwipeAction? = nil,
    trailing: ApolloSwipeAction? = nil,
    /// Mimimum distance for the drag gesture. Set to > 0 to avoid
    /// interfering with other gestures
    minDragDistance: CGFloat = 25,
    /// The distance after which selection will occur and letting go
    /// will trigger the action
    triggerDistance: CGFloat = 70,
    /// The width of the icon frame, in which it will be centered
    iconFrameWidth: CGFloat = 70,
    /// Whether or not you can continue to drag on the other side
    /// after having started a drag on one side
    allowsContinuousDrag: Bool = true,
    /// How much spacing will be between your view and the swipe action view
    actionSpacing: CGFloat = 0,
    /// Corner radius for the swipe actions views
    actionCornerRadius: CGFloat = 0
  ) -> some View {
    modifier(ApolloSwipeActionsModifier(
      leadingAction: leading,
      trailingAction: trailing,
      minDragDistance: minDragDistance,
      triggerDistance: triggerDistance,
      iconFrameWidth: iconFrameWidth,
      allowsContinuousDrag: allowsContinuousDrag,
      actionSpacing: actionSpacing,
      actionCornerRadius: actionCornerRadius
    ))
  }
}
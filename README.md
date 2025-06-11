Add customizable Apollo-style swipe actions to any SwiftUI view.

- Enable swipe actions on any view, not just list rows.
- Customize colors, icons, fonts, corner radius, spacing, etc...
- Default behavior inspired by the Apollo for Reddit app
- Made with 100% SwiftUI. Supports iOS 14+.


### Installation

ApolloSwipeActions is available via the [Swift Package Manager](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app). Alternatively, because all of ApolloSwipeActions is contained within a single file, drag [`SwipeActions.swift`](https://github.com/tarrouye/ApolloSwipeActions/blob/main/Sources/SwipeActions.swift) into your project. Requires iOS 15+.

```
https://github.com/tarrouye/ApolloSwipeActions
```

### Usage

Simply add the `.apolloSwipeActions`  modifier to your view, passing the (optional) leading and trailing items and customizing any behaviors as desired

```swift
import SwiftUI
import ApolloSwipeActions

struct ContentView: View {
  var body: some View {
    Text("Hello")
      .frame(maxWidth: .infinity)
      .padding(.vertical, 32)
      .background(Color.blue.opacity(0.1))
      .apolloSwipeActions(
        trailing: .init(
          color: .blue,
          icon: "chevron.backward",
          action: {
            print("Swipe action triggered !")
          }
        )
      )

    Text("Hello Rounded")
      .frame(maxWidth: .infinity)
      .padding(.vertical, 32)
      .background(Color.blue.opacity(0.1))
      .cornerRadius(32)
      .apolloSwipeActions(
        leading: .init(
          color: .green,
          icon: "chevron.forward",
          action: {
            print("Swipe action triggered !")
          }
        ),
        trailing: .init(
          color: .blue,
          icon: "chevron.backward",
          action: {
            print("Swipe action triggered !")
          }
        ),
        actionSpacing: 5,
        actionCornerRadius: 32
      )
      .padding()
  }
}
```

// Add video here

### Customization

ApolloSwipeActions supports several options for customization.

Each ApolloSwipeAction has its own: 
- Color
- Icon (sfsymbol image name)
- Foreground color (for the icon)
- Font (for the icon) (automatically bolded when selected, so recommend to use a regular weight)

And when adding the modifier you can customize several properties, which are explained here:

```swift
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
) -> some View
```

### Advanced Example

Here's a sample showing both a plain and rounded style list of emails with swipe actions allowing you to mark read/unread and delete mails

```swift
// MARK: - Usage Example
struct ApolloSwipeActionsExample: View {
  @State private var emails = [
    Email(
      id: 1,
      subject: "Meeting Tomorrow",
      isTall: false,
      isRead: false
    ),
    Email(
      id: 2,
      subject: "Project Update",
      isTall: true,
      isRead: true
    ),
    Email(
      id: 3,
      subject: "Lunch Plans",
      isTall: false,
      isRead: false
    )
  ]

  var body: some View {
    NavigationStack {
      List {
        ForEach(emails, id: \.id) { email in
          EmailRowView(email: email)
            .apolloSwipeActions(
              leading: ApolloSwipeAction(
                color: email.isRead ? .orange : .blue,
                icon: email.isRead ? "envelope.badge" : "envelope.open",
                action: {
                  toggleReadStatus(for: email.id)
                }
              ),
              trailing: ApolloSwipeAction(
                color: .red,
                icon: "trash.fill",
                action: {
                  deleteEmail(with: email.id)
                }
              )
            )
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        }

        Text("With corner radius:")
          .padding(.vertical, 40)
          .listRowSeparator(.hidden)

        ForEach(emails, id: \.id) { email in
          EmailRowView(email: email)
            .padding(2)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 5))
            .apolloSwipeActions(
              leading: ApolloSwipeAction(
                color: email.isRead ? .orange : .blue,
                icon: email.isRead ? "envelope.badge" : "envelope.open",
                action: {
                  toggleReadStatus(for: email.id)
                }
              ),
              trailing: ApolloSwipeAction(
                color: .red,
                icon: "trash.fill",
                action: {
                  deleteEmail(with: email.id)
                }
              ),
              actionSpacing: 5,
              actionCornerRadius: 5
            )
            .listRowInsets(.init(top: 0, leading: 10, bottom: 0, trailing: 10))
            .listRowSeparator(.hidden)
        }
      }
      .listStyle(.plain)
      .navigationTitle("Inbox")
    }
  }

  private func toggleReadStatus(for id: Int) {
    if let index = emails.firstIndex(where: { $0.id == id }) {
      emails[index].isRead.toggle()
    }
  }

  private func deleteEmail(with id: Int) {
    emails.removeAll { $0.id == id }
  }
}

// MARK: - Supporting Models and Views
struct Email: Identifiable {
  let id: Int
  let subject: String
  let isTall: Bool
  var isRead: Bool
}

struct EmailRowView: View {
  let email: Email

  var body: some View {
    HStack {
      Circle()
        .fill(email.isRead ? Color.clear : Color.blue)
        .frame(width: 8, height: 8)

      VStack(alignment: .leading) {
        Text(email.subject)
          .font(.headline)
          .foregroundColor(email.isRead ? .secondary : .primary)

        Text("Preview text would go here...")
          .font(.caption)
          .foregroundColor(.secondary)
          .lineLimit(1)

        if email.isTall {
          Color.clear.frame(height: 80)
        }
      }

      Spacer()
    }
    .padding(4)
  }
}

#Preview {
  ApolloSwipeActionsExample()
}
```

### License

```
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
```

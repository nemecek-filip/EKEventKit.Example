# EKEventKit Example

### Simple example project showing basic parts of Event Kit like loading events from calendar, selecting calendar, editing events..

📅 This project shows loading `EKEvent`s from `EKEventStore` and accessing their properties to display calendar events in a Table View. It also demonstrates usage of `EKCalendarChooser` to let user choose calendars whose events to display. Events are added and edited via `EKEventEditViewController`. Events with location can be displayed on a map.

Not related stuff includes using `NSTextAttachment` inside `NSAttributedString` to display calendar colors with tinted images. And also how to implement swipe to delete in Table View with custom icon with the `trailingSwipeActionsConfigurationForRowAt` method.

![](Images/showcase.png)

I also have smaller projects showing [EKCalendarChooser](https://github.com/nemecek-filip/EKCalendarChooser.Example) and [EKEventEditViewController](https://github.com/nemecek-filip/EKEventEditViewController.Example).
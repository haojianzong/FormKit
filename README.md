<p>
<img src="https://github.com/haojianzong/ObjectForm/blob/master/banner.png?raw=true"/>
</p>

ObjectForm
=======

A simple yet powerful library to build form for your class models.

<img width="200" src="https://github.com/haojianzong/ObjectForm/blob/master/demo.gif?raw=true" />

## Motivations

I found most form libraries for swift are too complicated to bootstrap a simple project. So I write ObjectForm to make it dead simple for building forms and binding model classes.

ObjectForm doesn't fight with you to write UIKit code. By design, it is simple to understand and extend. If you follow the example project carefully, you would find it easy to fit in your Swift project.

This project has no dependency of any other library.

## Features
- Bind class model to form rows
- Work well with UITableView
- Customize keyboards according to model types
- Type safe
- Form validation is supported
- A list of Built-in UITableViewCell to support multiple types

## Available Rows & Cells

### Rows

- `StringRow`: Row to support string input, full keyboard
- `DoubleRow`: Row to support number input, numeric keyboard
- `DateRow`: Row to bind Date value

### Cells

- `TextViewInputCell`: text input cell
- `SelectInputCell`: support selection, provided by `CollectionPicker`
- `TextViewVC`: A view controller with UITextView to input long text
- `ButtonCell`: Show a button in the form
- `TypedInputCell`: Generic cell to support type binding
- `FormInputCell`: The base class for all cells

## Usage

1. Copy sources

Copy files under [/Sources](https://github.com/haojianzong/ObjectForm/tree/master/ObjectFormExample/Sources) into your project.

2. Carthage (Coming soon)
2. Swift Package (Coming soon)

### Tutorials

You can follow the example in `ObjectFormExample` to learn how to build a simple form with a class model. 

### Binding Model to Form

```swift
class FruitFormData: NSObject, FormDataSource {
      // Bind your custom model
      typealias BindModel = Fruit
      var basicRows: [BaseRow] = []

      func numberOfSections() -> Int {...}
      func numberOfRows(at section: Int) -> Int {...}
      func row(at indexPath: IndexPath) -> BaseRow {...}

      self.bindModel = fruit

      basicRows.append(StringRow(title: "Name",
                                 icon: "",
                                 updateTag: "name",
                                 value: fruit.name ?? "",
                                 placeholder: nil,
                                 validation: nil))

      // Row are type safe
      basicRows.append(DoubleRow(title: "Price",
                                 icon: "",
                                 updateTag: "price",
                                 value: fruit.price,
                                 placeholder: "",
                                 validation: nil))

      // You can build as many rows as you want
      basicRows.append(TextViewRow(title: "Note",
                                   updateTag: "note",
                                   value: fruit.note ?? "-"))

  }
}
```

### Showing FormDataSource in a UITableView

```swift
class FruitFormVC: UIViewController {
  private let dataSource: FruitFormData
}

extension FruitFormVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.numberOfRows(at: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let row = dataSource.row(at: indexPath)
        row.baseCell.setup(row)
        row.baseCell.delegate = self
        return row.baseCell
    }
}

```

### Listening to Cell Value Change

```swift
extension FruitFormVC: FormCellDelegate {
    func cellDidChangeValue(_ cell: UITableViewCell, value: Any?) {
        let indexPath = tableView.indexPath(for: cell)!
        _ = dataSource.updateItem(at: indexPath, value: value)
    }
}
```

### Validate Data

<img width="300" src="https://github.com/haojianzong/ObjectForm/blob/master/validation.gif?raw=true" />

```swift
basicRows.append(StringRow(title: "Name",
                           icon: "",
                           updateTag: "name",
                           value: fruit.name ?? "",
                           placeholder: nil,
                           validation: {
                           // Custom rules for row validation
                            return !(fruit.name?.isEmpty ?? true)

}))
```

```swift
@objc private func saveButtonTapped() {
    guard dataSource.validateData() else {
        tableView.reloadData()
        return
    }

    navigationController?.popViewController(animated: true)
}
```

### Make Your Own Row

Making your own row and cell is easy. You have 2 options:

1. Create concrete type using `TypedRow`

```swift
typealias StringRow = TypedRow<String>
```

2. Subclass `BaseRow`

```swift
class TextViewRow: BaseRow {

    public override var baseCell: FormInputCell {
        return cell
    }

    public override var baseValue: CustomStringConvertible? {
        get { return value }
        set { value = newValue as? String }
    }

    var value: String?

    var cell: TextViewInputCell

    override var description: String {
        return "<TextViewRow> \(title ?? "")"
    }

    required init(title: String, updateTag: String, value: String?) {
        self.cell = TextViewInputCell()

        super.init()

        self.title = title
        self.updateTag = updateTag
        self.value = value
        self.placeholder = nil
    }
}
```

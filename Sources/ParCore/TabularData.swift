#if canImport(TabularData)
import TabularData
#else
import Foundation

/// Missing implementations simply delegate to `unimplemented`, which crashes the program with `fatalError("unimplemented")`
@inlinable func unimplemented() -> Never {
    fatalError("unimplemented")
}

// MARK: Protocols

/// Two-dimensional, size-mutable, potentially heterogeneous tabular data.
public protocol DataFrameProtocol {

    /// A type that conforms to the type-erased column protocol.
    associatedtype ColumnType : AnyColumnProtocol

    /// The underlying data frame.
    var base: DataFrame { get }

    /// The rows of the underlying data frame.
    var rows: DataFrame.Rows { get set }

    /// The columns of the underlying data frame.
    var columns: [Self.ColumnType] { get }

    /// The number or rows and columns of the data frame type.
    /// - Parameters:
    ///   - rows: The number of rows in the data frame type.
    ///   - columns: The number of columns in the data frame type.
    var shape: (rows: Int, columns: Int) { get }

    /// Accesses a slice of the data frame type with an index range.
    ///
    /// - Parameter range: An integer range.
    subscript(range: Range<Int>) -> DataFrame.Slice { get set }
}


/// A type that represents a column.
///
/// `ColumnProtocol` defines the common functionality for typed column types.
/// Its type-erased counterpart is ``AnyColumnProtocol``.
public protocol ColumnProtocol : BidirectionalCollection {

    /// The name of the column.
    var name: String { get set }
}

/// A type that represents a column that has missing values.
///
/// `OptionalColumnProtocol` defines the common functionality for column types that support missing values.
public protocol OptionalColumnProtocol : ColumnProtocol {

    /// The type of the optional column type's elements.
    associatedtype WrappedElement where Self.Element == Self.WrappedElement?
}


/// A type that represents a type-erased column.
///
/// `AnyColumnProtocol` defines the common functionality for type-erased column types.
/// Its typed counterpart is ``ColumnProtocol``.
public protocol AnyColumnProtocol {

    /// The name of the column type.
    var name: String { get set }

    /// The number of elements in the column type.
    var count: Int { get }

    /// The underlying type of the column type's elements.
    var wrappedElementType: Any.Type { get }

    /// Retrieves an element at a position in the column type.
    ///
    /// - Parameter position: A valid index in the column type.
    subscript(position: Int) -> Any? { get }

    /// Retrieves a contiguous subrange of the column type's elements.
    ///
    /// - Parameter range: An integer range of valid indices in the column.
    subscript(range: Range<Int>) -> AnyColumnSlice { get }
}

/// A prototype that creates type-erased columns.
public protocol AnyColumnPrototype {

    /// The name of the column.
    var name: String { get set }

    /// Creates a type-erased column.
    ///
    /// - Parameter capacity: The capacity of the new column.
    func makeColumn(capacity: Int) -> AnyColumn 
}


/// A type that represents a collection of row selections that have the same value in a column.
public protocol RowGroupingProtocol : CustomStringConvertible {

    /// The number of groups in the row grouping.
    var count: Int { get }

    /// Generates a data frame that contains all the rows from each group in the row grouping.
    ///
    /// A row grouping can only use this method if all its groups have the same column names and types.
    ///
    /// > Important: The method discards a column with the same name as the row grouping itself.
    func ungrouped() -> DataFrame 

    /// Generates a data frame, that you choose how to sort, with two columns, one that has a row for each group key and
    /// another for the number or rows in the group.
    ///
    /// - Parameter order: A sorting order the method uses to sort the data frame by its count column.
    ///
    /// The name of the data frame's column that stores the number of rows in each group is *count*.
    func counts(order: Order?) -> DataFrame 

    /// Generates a data frame by aggregating each group's contents for each column you select by name.
    ///
    /// - Parameters:
    ///   - columnNames: A comma-separated, or variadic, list of column names.
    ///   - naming: A closure that converts a column name to another name.
    ///   - transform: A closure that aggregates a group's elements in a specific column.
    ///
    /// The data frame contains two columns that:
    /// - Identify each group
    /// - Store the results of your aggregation transform closure
    func aggregated<Element, Result>(on columnNames: [String], naming: (String) -> String, transform: (DiscontiguousColumnSlice<Element>) throws -> Result?) rethrows -> DataFrame 

    /// Generates a new row grouping that applies a transformation closure to each group in the original.
    ///
    /// - Parameter transform: A closure that generates a data frame from a data frame slice that represents a group.
    func mapGroups(_ transform: (DataFrame.Slice) throws -> DataFrame) rethrows -> Self 

    /// Generates a data frame with a single row that summarizes the columns of the row grouping.
    func summaryOfAllColumns() -> DataFrame 

    /// Generates a data frame with a single row that summarizes the columns you select by name.
    ///
    /// - Parameter columnNames: An array of column names.
    func summary(of columnNames: [String]) -> DataFrame 

    /// Generates a data frame with a single row that numerically summarizes the columns you select by name.
    /// - Parameter columnNames: An array of column names.
    func numericSummary(of columnNames: [String]) -> DataFrame 

    /// Generates two row groupings by randomly splitting the original by a proportion.
    /// - Parameters:
    ///   - proportion: A proportion in the range `[0.0, 1.0]`.
    ///   - seed: A seed number for a random-number generator.
    /// - Returns: A tuple of two data row grouping types.
    func randomSplit(by proportion: Double, seed: Int?) -> (Self, Self) 
}




// MARK: Implementations



/// A type-erased column.
///
/// `AnyColumn` is a column type that conceals the type of its elements,
/// unlike ``Column``, its typed counterpart.
public struct AnyColumn : AnyColumnProtocol, Hashable {

    /// The name of the column.
    public var name: String

    /// The underlying type of the column’s elements.
    public var wrappedElementType: Any.Type { unimplemented() }

    /// A prototype that creates type-erased columns with the same underlying type as the column slice.
    ///
    /// Use a type-erased column prototype to create new columns of the same type as the slice's parent column
    /// without explicitly knowing what type it is, by calling
    /// the `prototype` property's ``AnyColumnPrototype/makeColumn(capacity:)`` method.
    ///
    /// ```swift
    /// // Get a type-erased column.
    /// let someColumn: AnyColumn = dataFrame["someFeature"]
    ///
    /// // Create a new column with the same type.
    /// let newColumn = someColumn.prototype.makeColumn(capacity: 10)
    /// ```
    public var prototype: AnyColumnPrototype { unimplemented() }

    /// The number of elements in the column.
    public var count: Int { unimplemented() }

    /// Returns the underlying typed column.
    ///
    /// When using this method, you must provide the correct underlying type.
    ///
    /// - Parameter type: The type of the underlying column.
    /// - Returns: A typed column.
    public func assumingType<T>(_ type: T.Type) -> Column<T> { unimplemented() }

    /// Returns a Boolean that indicates whether the element at the index is missing.
    ///
    /// - Parameter index: The location of an element in the column.
    public func isNil(at index: Int) -> Bool { unimplemented() }

    /// Appends an optional element to the column.
    ///
    /// - Parameter element: An element.
    public mutating func append(_ element: Any?) { unimplemented() }

    /// Appends the contents of another column to the column.
    ///
    /// - Parameter other: A column that contains elements of the same type as this column.
    public mutating func append(contentsOf other: AnyColumn) { unimplemented() }

    /// Appends the contents of a column slice to the column.
    ///
    /// - Parameter other: A column that contains elements of the same type as this column.
    public mutating func append(contentsOf other: AnyColumnSlice) { unimplemented() }

    /// Removes an element from the column.
    ///
    /// - Parameter index: The location of an element in the column.
    public mutating func remove(at index: Int) { unimplemented() }

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    public var hashValue: Int { unimplemented() }
}

extension AnyColumn {

    /// Generates a categorical summary of the column's elements that aren't missing.
    public func summary() -> CategoricalSummary<AnyHashable> { unimplemented() }
}

extension AnyColumn : RandomAccessCollection, MutableCollection {

    /// The index of the initial element in the column.
    public var startIndex: Int { unimplemented() }

    /// The index of the final element in the column.
    public var endIndex: Int { unimplemented() }

    /// Returns the index immediately after an element index.
    /// - Parameter i: A valid index to an element in the column.
    public func index(after i: Int) -> Int { unimplemented() }

    /// Returns the index immediately before an element index.
    /// - Parameter i: A valid index to an element in the column.
    public func index(before i: Int) -> Int { unimplemented() }

    /// Accesses an element at an index.
    ///
    /// - Parameter position: A valid index in the column.
    public subscript(position: Int) -> Any? { get { unimplemented() } set { unimplemented() } }

    /// Accesses a contiguous subrange of the elements.
    ///
    /// - Parameter range: A range of valid indices in the column.
    public subscript(range: Range<Int>) -> AnyColumnSlice { unimplemented() }

    /// Returns a slice of the column by selecting elements with a collection of Booleans.
    ///
    /// - Parameter mask: A collection of Booleans.
    /// The method selects the column's elements that correspond to the `true` elements in the collection.
    public subscript<C>(mask: C) -> AnyColumnSlice where C : Collection, C.Element == Bool { unimplemented() }

    /// Returns a Boolean that indicates whether the columns are equal.
    /// - Parameters:
    ///   - lhs: A type-erased column.
    ///   - rhs: Another type-erased column.
    public static func == (lhs: AnyColumn, rhs: AnyColumn) -> Bool { unimplemented() }

    /// Hashes the essential components of the column by feeding them into a hasher.
    /// - Parameter hasher: A hasher the method uses to combine the components of the column.
    public func hash(into hasher: inout Hasher) { unimplemented() }

    /// A type representing the sequence's elements.
    public typealias Element = Any?

    /// A type that represents a position in the collection.
    ///
    /// Valid indices consist of the position of every element and a
    /// "past the end" position that's not valid for use as a subscript
    /// argument.
    public typealias Index = Int

    /// A type that represents the indices that are valid for subscripting the
    /// collection, in ascending order.
    public typealias Indices = Range<Int>

    /// A type that provides the collection's iteration interface and
    /// encapsulates its iteration state.
    ///
    /// By default, a collection conforms to the `Sequence` protocol by
    /// supplying `IndexingIterator` as its associated `Iterator`
    /// type.
    public typealias Iterator = IndexingIterator<AnyColumn>

    /// A sequence that represents a contiguous subrange of the collection's
    /// elements.
    ///
    /// This associated type appears as a requirement in the `Sequence`
    /// protocol, but it is restated here with stricter constraints. In a
    /// collection, the subsequence should also conform to `Collection`.
    public typealias SubSequence = AnyColumnSlice
}

extension AnyColumn : CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {

    /// A text representation of the column.
    public var description: String { unimplemented() }

    /// A text representation of the column suitable for debugging.
    public var debugDescription: String { unimplemented() }

    /// A mirror that reflects the column.
    public var customMirror: Mirror { unimplemented() }
}

extension AnyColumn {

    /// Generates a column slice that contains unique elements.
    ///
    /// The method only adds the first of multiple elements with the same value
    /// --- the element with the smallest index ---
    /// to the slice.
    ///
    /// - Returns: A type-erased column slice.
    public func distinct() -> AnyColumnSlice { unimplemented() }
}


/// A type-erased column slice.
public struct AnyColumnSlice : AnyColumnProtocol, Hashable {

    /// The name of the slice's parent column.
    public var name: String

    /// The underlying type of the column’s elements.
    public var wrappedElementType: Any.Type { unimplemented() }

    /// The number of elements in the column slice.
    public var count: Int { unimplemented() }

    /// Returns a slice of the underlying typed column.
    ///
    /// When using this method, you must provide the correct underlying type.
    ///
    /// - Parameter type: The type of the slice's underlying parent column.
    /// - Returns: A typed column slice.
    public func assumingType<T>(_ type: T.Type) -> DiscontiguousColumnSlice<T> { unimplemented() }

    /// Returns a Boolean that indicates whether the element at the index is missing.
    ///
    /// - Parameter index: An index.
    public func isNil(at index: Int) -> Bool { unimplemented() }

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    public var hashValue: Int { unimplemented() }
}

extension AnyColumnSlice {

    /// Generates a categorical summary of the column slice's elements that aren't missing.
    public func summary() -> CategoricalSummary<AnyHashable> { unimplemented() }
}

extension AnyColumnSlice : RandomAccessCollection, MutableCollection {

    /// The index of the initial element in the column slice.
    public var startIndex: Int { unimplemented() }

    /// The index of the final element in the column slice.
    public var endIndex: Int { unimplemented() }

    /// Returns the index immediately after an element index.
    /// - Parameter i: A valid index to an element in the column slice.
    public func index(after i: Int) -> Int { unimplemented() }

    /// Returns the index immediately before an element index.
    /// - Parameter i: A valid index to an element in the column slice.
    public func index(before i: Int) -> Int { unimplemented() }

    /// Accesses an element at an index.
    ///
    /// - Parameter position: A valid index to an element in the column slice.
    public subscript(position: Int) -> Any? { get { unimplemented() } set { unimplemented() } }

    /// Accesses a contiguous range of elements.
    ///
    /// - Parameter range: A range of valid indices in the column slice.
    public subscript(range: Range<Int>) -> AnyColumnSlice { unimplemented() }

    /// Returns a Boolean that indicates whether the column slices are equal.
    /// - Parameters:
    ///   - lhs: A type-erased column slice.
    ///   - rhs: Another type-erased column slice.
    public static func == (lhs: AnyColumnSlice, rhs: AnyColumnSlice) -> Bool { unimplemented() }

    /// Hashes the essential components of the column slice by feeding them into a hasher.
    /// - Parameter hasher: A hasher the method uses to combine the components of the column slice.
    public func hash(into hasher: inout Hasher) { unimplemented() }

    /// A type representing the sequence's elements.
    public typealias Element = Any?

    /// A type that represents a position in the collection.
    ///
    /// Valid indices consist of the position of every element and a
    /// "past the end" position that's not valid for use as a subscript
    /// argument.
    public typealias Index = Int

    /// A type that represents the indices that are valid for subscripting the
    /// collection, in ascending order.
    public typealias Indices = Range<Int>

    /// A type that provides the collection's iteration interface and
    /// encapsulates its iteration state.
    ///
    /// By default, a collection conforms to the `Sequence` protocol by
    /// supplying `IndexingIterator` as its associated `Iterator`
    /// type.
    public typealias Iterator = IndexingIterator<AnyColumnSlice>

    /// A sequence that represents a contiguous subrange of the collection's
    /// elements.
    ///
    /// This associated type appears as a requirement in the `Sequence`
    /// protocol, but it is restated here with stricter constraints. In a
    /// collection, the subsequence should also conform to `Collection`.
    public typealias SubSequence = AnyColumnSlice
}

extension AnyColumnSlice : CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {

    /// A text representation of the column slice.
    public var description: String { unimplemented() }

    /// A text representation of the column slice suitable for debugging.
    public var debugDescription: String { unimplemented() }

    /// A mirror that reflects the column slice.
    public var customMirror: Mirror { unimplemented() }
}

extension AnyColumnSlice {

    /// Generates a column slice that contains unique elements.
    ///
    /// The method only adds the first of multiple elements with the same value
    /// --- the element with the smallest index ---
    /// to the slice.
    ///
    /// - Returns: A type-erased column slice.
    public func distinct() -> AnyColumnSlice { unimplemented() }
}

/// A CSV reading error.
public enum CSVReadingError : Error {

    /// An error that indicates CSV data contains an invalid UTF-8 byte sequence.
    ///
    /// - Parameters:
    ///   - row: The index of the row that contains the invalid sequence.
    ///   - column: The index of the column that contains the invalid sequence.
    ///   - cellContents: The data that contains the invalid sequence.
    case badEncoding(row: Int, column: Int, cellContents: Data)

    /// An error that indicates the CSV reader doesn't support an encoding.
    ///
    /// The associated value contains a description of the error.
    case unsupportedEncoding(String)

    /// An error that indicates the CSV data contains a misplaced quote.
    ///
    /// - Parameters:
    ///   - row: The index of the row that contains the misplaced quote.
    ///   - column: The index of the column that contains the misplaced quote.
    case misplacedQuote(row: Int, column: Int)

    /// An error that indicates the CSV data contains a row with a mismatched number of columns.
    ///
    /// - Parameters:
    ///   - row: The index of the row that contains the mismatched number of columns.
    ///   - columns: The number of columns in the row.
    ///   - expected: The number of columns in the other rows.
    case wrongNumberOfColumns(row: Int, columns: Int, expected: Int)

    /// An error that indicates the CSV reader can't parse data in the file.
    ///
    /// - Parameters:
    ///   - row: The index of the row that contains the invalid data.
    ///   - column: The index of the column that contains the invalid data.
    ///   - type: The type the CSV reader expects.
    ///   - cellContents: The data the CSV reader can't parse.
    case failedToParse(row: Int, column: Int, type: CSVType, cellContents: Data)

    /// The index of the row that contains the error.
    public var row: Int { unimplemented() }

    /// The index of the column that contains the error.
    public var column: Int? { unimplemented() }
}

extension CSVReadingError : CustomStringConvertible {

    /// A text representation of the reading error.
    public var description: String { unimplemented() }
}

/// A set of CSV file-reading options.
public struct CSVReadingOptions {

    /// A Boolean value that indicates whether the CSV file has a header row.
    ///
    /// Defaults to `true`.
    public var hasHeaderRow: Bool

    /// The set of strings that stores acceptable spellings for empty values.
    ///
    /// Defaults to `["", "#N/A", "#N/A N/A", "#NA", "N/A", "NA", "NULL", "n/a", "null"]`.
    public var nilEncodings: Set<String>

    /// The set of strings that stores acceptable spellings for true Boolean values.
    ///
    /// Defaults to `["1", "True", "TRUE", "true"]`.
    public var trueEncodings: Set<String>

    /// The set of strings that stores acceptable spellings for false Boolean values.
    ///
    /// Defaults to `["0", "False", "FALSE", "false"]`.
    public var falseEncodings: Set<String>

    /// The type to use for floating-point numeric values.
    ///
    /// Defaults to ``CSVType/double``.
    public var floatingPointType: CSVType

    /// An array of closures that parse a date from a string.
    public var dateParsers: [(String) -> Date?] { unimplemented() }

    /// A Boolean value that indicates whether to ignore empty lines.
    ///
    /// Defaults to `true`.
    public var ignoresEmptyLines: Bool

    /// A Boolean value that indicates whether to enable quoting.
    ///
    /// When `true`, the contents of a quoted field can contain special characters, such as the field
    /// delimiter and newlines. Defaults to `true`.
    public var usesQuoting: Bool

    /// A Boolean value that indicates whether to enable escaping.
    ///
    /// When `true`, you can escape special characters, such as the field delimiter, by prefixing them with
    /// the escape character, which is the backslash (`\`) by default. Defaults to `false`.
    public var usesEscaping: Bool

    /// The character that separates data fields in a CSV file, typically a comma.
    ///
    /// Defaults to comma (`,`).
    public var delimiter: Character { unimplemented() }

    /// The character that precedes other characters, such as quotation marks,
    /// so that the parser interprets them as literal characters instead of special ones.
    ///
    /// Defaults to backslash(`\`).
    public var escapeCharacter: Character { unimplemented() }

    /// Creates a set of options for reading a CSV file.
    ///
    /// - Parameters:
    ///   - hasHeaderRow: A Boolean value that indicates whether the CSV file has a header row. Defaults to `true`.
    ///   - nilEncodings: A list of recognized encodings of `nil`. Defaults to
    ///     `["", "#N/A", "#N/A N/A", "#NA", "N/A", "NA", "NULL", "n/a", "null"]`.
    ///   - trueEncodings: A list of acceptable encodings of `true`. Defaults to `["1", "True", "TRUE", "true"]`.
    ///   - falseEncodings: A list of acceptable encodings of `false`. Defaults to `["0", "False", "FALSE", "false"]`.
    ///   - floatingPointType: A type to use for floating-point numeric values
    ///   (either ``CSVType/double`` or ``CSVType/float``).
    ///     Defaults to ``CSVType/double``.
    ///   - ignoresEmptyLines: A Boolean value that indicates whether to ignore empty lines. Defaults to `true.`
    ///   - usesQuoting: A Boolean value that indicates whether the CSV file uses quoting. Defaults to `true`.
    ///   - usesEscaping: A Boolean value that indicates whether the CSV file uses escaping sequences. Defaults to
    ///     `false`.
    ///   - delimiter: A field delimiter. Defaults to comma (`,`).
    ///   - escapeCharacter: An escape character to use if ``usesEscaping`` is true. Defaults to backslash (`\`).
    public init(hasHeaderRow: Bool = true, nilEncodings: Set<String> = ["", "#N/A", "#N/A N/A", "#NA", "N/A", "NA", "NULL", "n/a", "nil", "null"], trueEncodings: Set<String> = ["1", "True", "TRUE", "true"], falseEncodings: Set<String> = ["0", "False", "FALSE", "false"], floatingPointType: CSVType = .double, ignoresEmptyLines: Bool = true, usesQuoting: Bool = true, usesEscaping: Bool = false, delimiter: Character = Character(","), escapeCharacter: Character = Character("\\")) { unimplemented() }

    /// Adds a date parsing strategy.
    /// - Parameter strategy: A parsing strategy that has a string input and a date output.
    //@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    //public mutating func addDateParseStrategy<T>(_ strategy: T) where T : ParseStrategy, T.ParseInput == String, T.ParseOutput == Date { unimplemented() }
}

/// Represents the value types in a CSV file.
public enum CSVType {

    /// An integer type.
    case integer

    /// A Boolean type.
    case boolean

    /// A single-precision floating-point type.
    case float

    /// A double-precision floating-point type.
    case double

    /// A date type.
    case date

    /// A string type.
    case string

    /// A binary data type.
    case data

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: CSVType, b: CSVType) -> Bool { unimplemented() }

    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// Implement this method to conform to the `Hashable` protocol. The
    /// components used for hashing must be the same as the components compared
    /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
    /// with each of these components.
    ///
    /// - Important: Never call `finalize()` on `hasher`. Doing so may become a
    ///   compile-time error in the future.
    ///
    /// - Parameter hasher: The hasher to use when combining the components
    ///   of this instance.
    public func hash(into hasher: inout Hasher) { unimplemented() }

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    public var hashValue: Int { unimplemented() }
}

extension CSVType : Equatable {
}

extension CSVType : Hashable {
}

/// A CSV writing error.
public enum CSVWritingError : Error {

    /// An error that indicates CSV data contains an invalid UTF-8 byte sequence.
    ///
    /// - Parameters:
    ///   - row: The index of the row that contains the invalid sequence.
    ///   - column: The index of the column that contains the invalid sequence.
    ///   - data: The data that contains the invalid sequence.
    case badEncoding(row: Int, column: String, Data)

    /// The index of the row that contains the error.
    public var row: Int { unimplemented() }

    /// The index of the column that contains the error.
    public var column: String? { unimplemented() }
}

extension CSVWritingError : CustomStringConvertible {

    /// A text representation of the writing error.
    public var description: String { unimplemented() }
}

/// A set of CSV file-writing options.
public struct CSVWritingOptions {

    /// A Boolean value that indicates whether to write a header with the column names.
    ///
    /// Defaults to `true`.
    public var includesHeader: Bool

    /// The format the CSV file generator uses to create date strings.
    ///
    /// Defaults to `nil`, which uses ISO 8601 encoding.
    public var dateFormat: String?

    /// The string the CSV file generator uses to represent nil values.
    ///
    /// Defaults to an empty string.
    public var nilEncoding: String

    /// The string the CSV file generator uses to represent true Boolean values.
    ///
    /// Defaults to `true`.
    public var trueEncoding: String

    /// The string the CSV file generator uses to represent false Boolean values.
    ///
    /// Defaults to `false`.
    public var falseEncoding: String

    /// The string the CSV file generator uses to represent a newline sequence.
    ///
    /// Defaults to a line feed.
    public var newline: String

    /// The character the CSV file generator uses to separate data fields in a CSV file.
    ///
    /// Defaults to comma (`,`).
    public var delimiter: Character

    /// Creates a set of options for writing a CSV file.
    /// - Parameters:
    ///   - includesHeader: A Boolean value that indicates whether to write a header with the column names. Defaults to
    ///     `true`.
    ///   - dateFormat: A date format to use for dates. Defaults to `nil`, which uses ISO 8601 encoding.
    ///   - nilEncoding: The spelling for nil values. Defaults to an empty string.
    ///   - trueEncoding: The spelling for true Boolean values. Defaults to `true`.
    ///   - falseEncoding: The spelling for false Boolean values. Defaults to `false`.
    ///   - newline: The newline sequence. Defaults to a line feed.
    ///   - delimiter: The field delimiter. Defaults to comma (`,`).
    public init(includesHeader: Bool = true, dateFormat: String? = nil, nilEncoding: String = "", trueEncoding: String = "true", falseEncoding: String = "false", newline: String = "\n", delimiter: Character = ",") { unimplemented() }
}

/// A categorical summary of a collection's elements.
///
/// Each categorical summary has four statistics about a collection:
///   - `count`: The total number of elements.
///   - `uniqueCount`: The number of unique elements.
///   - `top`: The most common element value, which is an
///   <doc://com.apple.documentation/documentation/Swift/Optional> of any type that conforms to
///   <doc://com.apple.documentation/documentation/Swift/Hashable>.
///   - `topFrequency`: The number of elements equal to `top`.
public struct CategoricalSummary<Element> : Hashable, CustomStringConvertible where Element : Hashable {

    /// The number of elements in a column, ignoring missing elements.
    public var count: Int

    /// The number of elements with distinct values in a column, ignoring missing elements.
    public var uniqueCount: Int

    /// The most common value in a column, ignoring missing elements.
    public var top: Element?

    /// The number of elements with the most common value in the column, ignoring missing elements.
    public var topFrequency: Int

    /// Creates a categorical summary for a collection.
    ///
    /// - Parameters:
    ///   - count: The number of elements in column, ignoring missing elements.
    ///   - uniqueCount: The number of elements with distinct values in a column, ignoring missing elements.
    ///   - top: The most common value in a column, ignoring missing elements.
    ///   - topFrequency: The number of elements with the most common value in the column,
    ///   ignoring missing elements.
    public init(count: Int, uniqueCount: Int, top: Element?, topFrequency: Int) { unimplemented() }

    /// A text representation of the summary's statistics.
    public var description: String { unimplemented() }

    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// Implement this method to conform to the `Hashable` protocol. The
    /// components used for hashing must be the same as the components compared
    /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
    /// with each of these components.
    ///
    /// - Important: Never call `finalize()` on `hasher`. Doing so may become a
    ///   compile-time error in the future.
    ///
    /// - Parameter hasher: The hasher to use when combining the components
    ///   of this instance.
    public func hash(into hasher: inout Hasher) { unimplemented() }

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: CategoricalSummary<Element>, b: CategoricalSummary<Element>) -> Bool { unimplemented() }

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    public var hashValue: Int { unimplemented() }
}

/// A column in a data frame.
///
/// A column is a <doc://com.apple.documentation/documentation/Swift/Collection> that contains
/// values of a specific type, including:
/// - <doc://com.apple.documentation/documentation/Swift/Int>
/// - <doc://com.apple.documentation/documentation/Swift/Double>
/// - <doc://com.apple.documentation/documentation/Swift/String>
///
/// Each element in a column is an
/// <doc://com.apple.documentation/documentation/Swift/Optional>
/// of the column's type. Each `nil` element represents a missing value.
public struct Column<WrappedElement> : OptionalColumnProtocol {

    /// The type of the column's elements, which is an optional type of the column's type.
    public typealias Element = WrappedElement?

    /// The name of the column.
    public var name: String

    /// The number of elements in the column.
    public var count: Int { unimplemented() }

    /// The underlying type of the column’s elements.
    public var wrappedElementType: Any.Type { unimplemented() }

    /// A prototype that creates type-erased columns with the same underlying type as the column slice.
    ///
    /// Use a type-erased column prototype to create new columns of the same type as the slice's parent column
    /// without explicitly knowing what type it is.
    public var prototype: AnyColumnPrototype { unimplemented() }

    /// Creates a column with a name and a capacity.
    ///
    /// - Parameters:
    ///   - name: The name of the column.
    ///   - capacity: The number of elements the column allocates memory for.
    public init(name: String, capacity: Int) { unimplemented() }

    /// Creates a column with a name and a sequence of optional values.
    ///
    /// - Parameters:
    ///   - name: A column name.
    ///   - contents: A sequence of optional elements.
    public init<S>(name: String, contents: S) where S : Sequence, S.Element == Column<WrappedElement>.Element { unimplemented() }

    /// Creates a column with a name and a sequence of nonoptional values.
    ///
    /// - Parameters:
    ///   - name: A column name.
    ///   - contents: A sequence of nonoptional elements.
    public init<S>(name: String, contents: S) where WrappedElement == S.Element, S : Sequence { unimplemented() }

    /// Creates a column with a column identifier and a sequence of optional values.
    ///
    /// - Parameters:
    ///   - id: A column identifier.
    ///   - contents: A sequence of optional elements.
    public init<S>(_ id: ColumnID<S.Element>, contents: S) where S : Sequence, S.Element == Column<WrappedElement>.Element { unimplemented() }

    /// Creates a column with an identifier and a sequence of nonoptional values.
    ///
    /// - Parameters:
    ///   - id: A column identifier.
    ///   - contents: A sequence of elements.
    public init<S>(_ id: ColumnID<S.Element>, contents: S) where WrappedElement == S.Element, S : Sequence { unimplemented() }

    /// Creates a column from a column slice.
    ///
    /// - Parameter slice: A column slice.
    public init(_ slice: ColumnSlice<WrappedElement>) { unimplemented() }

    /// Appends an optional value to the column.
    ///
    /// - Parameter element: A nonoptional element.
    public mutating func append(_ element: Column<WrappedElement>.Element) { unimplemented() }

    /// Appends a nonoptional value to the column.
    ///
    /// - Parameter element: An optional element.
    public mutating func append(_ element: WrappedElement) { unimplemented() }

    /// Appends a sequence of optional values to the column.
    ///
    /// - Parameter sequence: A sequence of optional elements.
    public mutating func append<S>(contentsOf sequence: S) where S : Sequence, S.Element == Column<WrappedElement>.Element { unimplemented() }

    /// Appends a sequence of nonoptional values to the column.
    ///
    /// - Parameter sequence: A sequence of nonoptional elements.
    public mutating func append<S>(contentsOf sequence: S) where WrappedElement == S.Element, S : Sequence { unimplemented() }

    /// Removes an element from the column.
    ///
    /// - Parameter index: The element's location in the column.
    public mutating func remove(at index: Int) { unimplemented() }

    /// Creates a new column by applying a transformation to every element.
    ///
    /// - Parameter transform: A transformation closure.
    public func map<T>(_ transform: (Column<WrappedElement>.Element) throws -> T?) rethrows -> Column<T> { unimplemented() }

    /// Creates a new column by applying the transformation to every element that isn't missing.
    ///
    /// - Parameter transform: A transformation closure.
    public func mapNonNil<T>(_ transform: (WrappedElement) throws -> T?) rethrows -> Column<T> { unimplemented() }

    /// Applies a transformation to every element in the column.
    ///
    /// - Parameter transform: A transformation closure.
    public mutating func transform(_ transform: (Column<WrappedElement>.Element) throws -> Column<WrappedElement>.Element) rethrows { unimplemented() }

    /// Applies a transformation to every element that isn't missing.
    ///
    /// - Parameter transform: A transformation closure.
    public mutating func transform(_ transform: (WrappedElement) throws -> WrappedElement) rethrows { unimplemented() }

    /// Generates a slice that contains the elements that satisfy a predicate.
    ///
    /// - Parameter isIncluded: A predicate closure that returns a Boolean.
    /// The method uses the closure to determine whether it includes an element in the slice.
    public func filter(_ isIncluded: (Column<WrappedElement>.Element) throws -> Bool) rethrows -> DiscontiguousColumnSlice<WrappedElement> { unimplemented() }

    /// Generates a type-erased copy of the column.
    public func eraseToAnyColumn() -> AnyColumn { unimplemented() }

    /// A type that represents a position in the collection.
    ///
    /// Valid indices consist of the position of every element and a
    /// "past the end" position that's not valid for use as a subscript
    /// argument.
    public typealias Index = Int

    /// A type that represents the indices that are valid for subscripting the
    /// collection, in ascending order.
    public typealias Indices = Range<Int>

    /// A type that provides the collection's iteration interface and
    /// encapsulates its iteration state.
    ///
    /// By default, a collection conforms to the `Sequence` protocol by
    /// supplying `IndexingIterator` as its associated `Iterator`
    /// type.
    public typealias Iterator = IndexingIterator<Column<WrappedElement>>

    /// A sequence that represents a contiguous subrange of the collection's
    /// elements.
    ///
    /// This associated type appears as a requirement in the `Sequence`
    /// protocol, but it is restated here with stricter constraints. In a
    /// collection, the subsequence should also conform to `Collection`.
    public typealias SubSequence = ColumnSlice<WrappedElement>
}

extension Column where WrappedElement : Hashable {

    /// Generates a categorical summary of the column's elements that aren't missing.
    public func summary() -> CategoricalSummary<WrappedElement> { unimplemented() }
}

extension Column : RandomAccessCollection, MutableCollection {

    /// The index of the initial element in the column.
    public var startIndex: Int { unimplemented() }

    /// The index of the final element in the column.
    public var endIndex: Int { unimplemented() }

    /// Returns the index immediately after an element index.
    /// - Parameter i: A valid index to an element in the column.
    public func index(after i: Int) -> Int { unimplemented() }

    /// Returns the index immediately before an element index.
    /// - Parameter i: A valid index to an element in the column.
    public func index(before i: Int) -> Int { unimplemented() }

    /// Accesses an element at an index.
    ///
    /// - Parameter position: A valid index to an element in the column.
    public subscript(position: Int) -> Column<WrappedElement>.Element { get { unimplemented() } set { unimplemented() } }

    /// Accesses a contiguous range of elements.
    ///
    /// - Parameter bounds: A range of valid indices in the column.
    public subscript(bounds: Range<Int>) -> ColumnSlice<WrappedElement> { unimplemented() }

    /// Accesses a contiguous range of elements with a range expression.
    ///
    /// - Parameter range: An integer range expression that represents valid indices in the column.
    @inlinable public subscript<R>(range: R) -> ColumnSlice<WrappedElement> where R : RangeExpression, R.Bound == Int { unimplemented() }

    /// Returns a column slice that includes elements that correspond to a collection of Booleans.
    ///
    /// - Parameter mask: A Boolean collection. The subscript returns a slice that includes the column elements
    /// that correspond to the `true` elements in `mask`.
    ///
    /// You can create a Boolean column for this subscript by comparing a column to a value
    /// of the column elements' type.
    ///
    /// ```swift
    /// let followerColumn = artists["Followers", Int.self].filled(with: 0)
    /// let popularArtists = artists[followerColumn > 10_000_000]
    /// ```
    public subscript<C>(mask: C) -> DiscontiguousColumnSlice<WrappedElement> where C : Collection, C.Element == Bool { unimplemented() }
}

extension Column : Equatable where WrappedElement : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: Column<WrappedElement>, b: Column<WrappedElement>) -> Bool { unimplemented() }
}

extension Column : Hashable where WrappedElement : Hashable {

    /// Generates a discontiguous slice that contains unique elements.
    ///
    /// The method only adds the first of multiple elements with the same value
    /// --- the element with the smallest index ---
    /// to the slice.
    ///
    /// - Returns: A discontiguous column slice.
    public func distinct() -> DiscontiguousColumnSlice<WrappedElement> { unimplemented() }

    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// Implement this method to conform to the `Hashable` protocol. The
    /// components used for hashing must be the same as the components compared
    /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
    /// with each of these components.
    ///
    /// - Important: Never call `finalize()` on `hasher`. Doing so may become a
    ///   compile-time error in the future.
    ///
    /// - Parameter hasher: The hasher to use when combining the components
    ///   of this instance.
    public func hash(into hasher: inout Hasher) { unimplemented() }

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    public var hashValue: Int { unimplemented() }
}

extension Column : Encodable where WrappedElement : Encodable {

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws { unimplemented() }
}

extension Column : Decodable where WrappedElement : Decodable {

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws { unimplemented() }
}

extension Column {

    /// Modifies a column by adding a value to each element.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A value of the same type as the column's elements.
    public static func += (lhs: inout Column<WrappedElement>, rhs: WrappedElement) where WrappedElement : AdditiveArithmetic { unimplemented() }

    /// Modifies a column by subtracting a value from each element.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A value of the same type as the column's elements.
    public static func -= (lhs: inout Column<WrappedElement>, rhs: WrappedElement) where WrappedElement : AdditiveArithmetic { unimplemented() }

    /// Modifies a column by multiplying each element by a value.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A value of the same type as the column's elements.
    public static func *= (lhs: inout Column<WrappedElement>, rhs: WrappedElement) where WrappedElement : Numeric { unimplemented() }

    /// Modifies an integer column by dividing each element by a value.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A value of the same type as the column's elements.
    public static func /= (lhs: inout Column<WrappedElement>, rhs: WrappedElement) where WrappedElement : BinaryInteger { unimplemented() }

    /// Modifies a floating-point column by dividing each element by a value.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A value of the same type as the column's elements.
    public static func /= (lhs: inout Column<WrappedElement>, rhs: WrappedElement) where WrappedElement : FloatingPoint { unimplemented() }
}

extension Column {

    /// Modifies a column by adding each value in a collection to
    /// the corresponding element in the column.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func += <C>(lhs: inout Column<WrappedElement>, rhs: C) where WrappedElement : AdditiveArithmetic, WrappedElement == C.Element, C : Collection { unimplemented() }

    /// Modifies a column by adding each optional value in a collection to
    /// the corresponding element in the column.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func += <C>(lhs: inout Column<WrappedElement>, rhs: C) where WrappedElement : AdditiveArithmetic, C : Collection, C.Element == WrappedElement? { unimplemented() }

    /// Modifies a column by subtracting each value in a collection from
    /// the corresponding element in the column.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func -= <C>(lhs: inout Column<WrappedElement>, rhs: C) where WrappedElement : AdditiveArithmetic, WrappedElement == C.Element, C : Collection { unimplemented() }

    /// Modifies a column by subtracting each optional value in a collection from
    /// the corresponding element in the column.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func -= <C>(lhs: inout Column<WrappedElement>, rhs: C) where WrappedElement : AdditiveArithmetic, C : Collection, C.Element == WrappedElement? { unimplemented() }

    /// Modifies a column by multiplying each element in the column by
    /// the corresponding value in a collection.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func *= <C>(lhs: inout Column<WrappedElement>, rhs: C) where WrappedElement : Numeric, WrappedElement == C.Element, C : Collection { unimplemented() }

    /// Modifies a column by multiplying each element in the column by
    /// the corresponding optional value in a collection.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func *= <C>(lhs: inout Column<WrappedElement>, rhs: C) where WrappedElement : Numeric, C : Collection, C.Element == WrappedElement? { unimplemented() }

    /// Modifies an integer column by dividing each element in the column by
    /// the corresponding value in a collection.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func /= <C>(lhs: inout Column<WrappedElement>, rhs: C) where WrappedElement : BinaryInteger, WrappedElement == C.Element, C : Collection { unimplemented() }

    /// Modifies an integer column by dividing each element in the column by
    /// the corresponding optional value in a collection.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func /= <C>(lhs: inout Column<WrappedElement>, rhs: C) where WrappedElement : BinaryInteger, C : Collection, C.Element == WrappedElement? { unimplemented() }

    /// Modifies a floating-point column by dividing each element in the column by
    /// the corresponding value in a collection.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func /= <C>(lhs: inout Column<WrappedElement>, rhs: C) where WrappedElement : FloatingPoint, WrappedElement == C.Element, C : Collection { unimplemented() }

    /// Modifies a floating-point column by dividing each element in the column by
    /// the corresponding optional value in a collection.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func /= <C>(lhs: inout Column<WrappedElement>, rhs: C) where WrappedElement : FloatingPoint, C : Collection, C.Element == WrappedElement? { unimplemented() }
}

extension Column where WrappedElement : Comparable {

    /// Returns the element with the lowest value, ignoring missing elements.
    public func min() -> Column<WrappedElement>.Element { unimplemented() }

    /// Returns the element with the highest value, ignoring missing elements.
    public func max() -> Column<WrappedElement>.Element { unimplemented() }

    /// Returns the index of the element with the lowest value, ignoring missing elements.
    public func argmin() -> Int? { unimplemented() }

    /// Returns the index of the element with the highest value, ignoring missing elements.
    public func argmax() -> Int? { unimplemented() }
}

extension Column where WrappedElement : AdditiveArithmetic {

    /// Returns the sum of the column's elements, ignoring missing elements.
    public func sum() -> WrappedElement { unimplemented() }
}

extension Column where WrappedElement : FloatingPoint {

    /// Returns the mean average of the floating-point column's elements, ignoring missing elements.
    public func mean() -> Column<WrappedElement>.Element { unimplemented() }

    /// Returns the standard deviation of the floating-point column's elements, ignoring missing elements.
    ///
    /// - Parameter deltaDegreesOfFreedom: A nonnegative integer.
    /// The method calculates the standard deviation's divisor by subtracting this parameter from the number of
    /// non-`nil` elements (`n - deltaDegreesOfFreedom` where `n` is the number of non-`nil` elements).
    ///
    /// - Returns: The standard deviation; otherwise, `nil` if there are fewer than
    /// `deltaDegreesOfFreedom + 1` non-`nil` items in the column.
    public func standardDeviation(deltaDegreesOfFreedom: Int = 1) -> Column<WrappedElement>.Element { unimplemented() }
}

extension Column where WrappedElement : BinaryInteger {

    /// Returns the mean average of the integer column's elements, ignoring missing elements.
    public func mean() -> Double? { unimplemented() }

    /// Returns the standard deviation of the integer column's elements, ignoring missing elements.
    ///
    /// - Parameter deltaDegreesOfFreedom: A nonnegative integer.
    /// The method calculates the standard deviation's divisor by subtracting this parameter from the number of
    /// non-`nil` elements (`n - deltaDegreesOfFreedom` where `n` is the number of non-`nil` elements).
    ///
    /// - Returns: The standard deviation; otherwise, `nil` if there are fewer than
    /// `deltaDegreesOfFreedom + 1` non-`nil` items in the column.
    public func standardDeviation(deltaDegreesOfFreedom: Int = 1) -> Double? { unimplemented() }
}

extension Column : CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {

    /// A text representation of the column.
    public var description: String { unimplemented() }

    /// A text representation of the column suitable for debugging.
    public var debugDescription: String { unimplemented() }

    /// A mirror that reflects the column.
    public var customMirror: Mirror { unimplemented() }
}

extension Column where WrappedElement : FloatingPoint {

    /// Generates a numeric summary of the floating-point column's elements.
    public func numericSummary() -> NumericSummary<WrappedElement> { unimplemented() }
}

extension Column where WrappedElement : BinaryInteger {

    /// Generates a numeric summary of the integer column's elements.
    public func numericSummary() -> NumericSummary<Double> { unimplemented() }
}

/// A column decoding error.
///
/// This error wraps a decoding error and includes the column name and row index where the decoding error occurs.
public struct ColumnDecodingError : Error, LocalizedError, CustomDebugStringConvertible {

    /// The name of the column with the error.
    public var columnName: String

    /// The index of the column's element with the error.
    public var rowIndex: Int

    /// The underlying decoding error.
    public var decodingError: DecodingError

    /// Creates a column decoding error.
    ///
    /// - Parameters:
    ///   - columnName: The name of the column with the error.
    ///   - rowIndex: The index of the column's element with the error.
    ///   - decodingError: An underlying decoding error.
    public init(columnName: String, rowIndex: Int, decodingError: DecodingError) { unimplemented() }

    /// A text representation of the column decoding error suitable for debugging.
    public var debugDescription: String { unimplemented() }
}

/// A column encoding error.
///
/// An error bundles an
/// <doc://com.apple.documentation/documentation/Swift/EncodingError>
/// with the row and column that produces the error.
public struct ColumnEncodingError : Error, LocalizedError, CustomDebugStringConvertible {

    /// The name of the column with the error.
    public var columnName: String

    /// The index of the column's element with the error.
    public var rowIndex: Int

    /// The underlying encoding error.
    public var encodingError: EncodingError

    /// Creates a column encoding error.
    ///
    /// - Parameters:
    ///   - columnName: The name of the column with the error.
    ///   - rowIndex: The index of the column's element with the error.
    ///   - encodingError: An underlying encoding error.
    public init(columnName: String, rowIndex: Int, encodingError: EncodingError) { unimplemented() }

    /// A text representation of the column encoding error suitable for debugging.
    public var debugDescription: String { unimplemented() }
}

/// A column identifier that stores a column's name and the type of its elements.
public struct ColumnID<T> {

    /// The name of the column the identifier represents.
    public var name: String

    /// Creates a column identifier.
    ///
    /// - Parameters:
    ///   - name: The name of a column.
    ///   - type: The type of the column's elements.
    public init(_ name: String, _ type: T.Type) { unimplemented() }
}

extension ColumnID : CustomStringConvertible {

    /// A text representation of the column identifier.
    public var description: String { unimplemented() }
}

extension ColumnProtocol where Self.Element : AdditiveArithmetic {

    /// Generates a column by adding each element in a column type to the corresponding elements of another.
    /// - Parameters:
    ///   - lhs: A column type.
    ///   - rhs: Another column type.
    /// - Returns: A new column.
    public static func + (lhs: Self, rhs: Self) -> Column<Self.Element> { unimplemented() }

    /// Generates a column by subtracting each element in a column type from the corresponding elements of another.
    /// - Parameters:
    ///   - lhs: A column type.
    ///   - rhs: Another column type.
    /// - Returns: A new column.
    public static func - (lhs: Self, rhs: Self) -> Column<Self.Element> { unimplemented() }
}

extension ColumnProtocol where Self.Element : Numeric {

    /// Generates a column by multiplying each element in a column type by the corresponding elements of another.
    /// - Parameters:
    ///   - lhs: A column type.
    ///   - rhs: Another column type.
    /// - Returns: A new column.
    public static func * (lhs: Self, rhs: Self) -> Column<Self.Element> { unimplemented() }
}

extension ColumnProtocol where Self.Element : BinaryInteger {

    /// Generates an integer column by dividing each element in a column type by the corresponding elements of another.
    /// - Parameters:
    ///   - lhs: A column type.
    ///   - rhs: Another column type.
    /// - Returns: A new column.
    public static func / (lhs: Self, rhs: Self) -> Column<Self.Element> { unimplemented() }
}

extension ColumnProtocol where Self.Element : FloatingPoint {

    /// Generates a floating-point column by dividing each element in a column type
    /// by the corresponding elements of another.
    /// - Parameters:
    ///   - lhs: A column type.
    ///   - rhs: Another column type.
    /// - Returns: A new column.
    public static func / (lhs: Self, rhs: Self) -> Column<Self.Element> { unimplemented() }
}

extension ColumnProtocol {

    /// Generates a column by adding a value to each element in a column.
    /// - Parameters:
    ///   - lhs: A column type.
    ///   - rhs: A value of the same type as the column.
    /// - Returns: A new column.
    public static func + (lhs: Self, rhs: Self.Element) -> Column<Self.Element> where Self.Element : AdditiveArithmetic { unimplemented() }

    /// Generates a column by adding each element in a column to a value.
    /// - Parameters:
    ///   - lhs: A value of the same type as the column.
    ///   - rhs: A column type.
    /// - Returns: A new column.
    public static func + (lhs: Self.Element, rhs: Self) -> Column<Self.Element> where Self.Element : AdditiveArithmetic { unimplemented() }

    /// Generates a column by subtracting a value from each element in a column.
    /// - Parameters:
    ///   - lhs: A column type.
    ///   - rhs: A value of the same type as the column.
    /// - Returns: A new column.
    public static func - (lhs: Self, rhs: Self.Element) -> Column<Self.Element> where Self.Element : AdditiveArithmetic { unimplemented() }

    /// Generates a column by subtracting each element in a column from a value.
    /// - Parameters:
    ///   - lhs: A value of the same type as the column.
    ///   - rhs: A column type.
    /// - Returns: A new column.
    public static func - (lhs: Self.Element, rhs: Self) -> Column<Self.Element> where Self.Element : AdditiveArithmetic { unimplemented() }
}

extension ColumnProtocol where Self.Element : Numeric {

    /// Generates a column by multiplying each element in a column by a value.
    /// - Parameters:
    ///   - lhs: A column type.
    ///   - rhs: A value of the same type as the column.
    /// - Returns: A new column.
    public static func * (lhs: Self, rhs: Self.Element) -> Column<Self.Element> { unimplemented() }

    /// Generates a column by multiplying a value by each element in a column.
    /// - Parameters:
    ///   - lhs: A value of the same type as the column.
    ///   - rhs: A column type.
    /// - Returns: A new column.
    public static func * (lhs: Self.Element, rhs: Self) -> Column<Self.Element> { unimplemented() }
}

extension ColumnProtocol where Self.Element : BinaryInteger {

    /// Generates an integer column by dividing each element in a column by a value.
    /// - Parameters:
    ///   - lhs: A column type.
    ///   - rhs: A value of the same type as the column.
    /// - Returns: A new column.
    public static func / (lhs: Self, rhs: Self.Element) -> Column<Self.Element> { unimplemented() }

    /// Generates an integer column by dividing a value by each element in a column.
    /// - Parameters:
    ///   - lhs: A value of the same type as the column.
    ///   - rhs: A column type.
    /// - Returns: A new column.
    public static func / (lhs: Self.Element, rhs: Self) -> Column<Self.Element> { unimplemented() }
}

extension ColumnProtocol where Self.Element : FloatingPoint {

    /// Generates a floating-point column by dividing each element in a column by a value.
    /// - Parameters:
    ///   - lhs: A column type.
    ///   - rhs: A value of the same type as the column.
    /// - Returns: A new column.
    public static func / (lhs: Self, rhs: Self.Element) -> Column<Self.Element> { unimplemented() }

    /// Generates a floating-point column by dividing a value by each element in a column.
    /// - Parameters:
    ///   - lhs: A value of the same type as the column.
    ///   - rhs: A column type.
    /// - Returns: A new column.
    public static func / (lhs: Self.Element, rhs: Self) -> Column<Self.Element> { unimplemented() }
}

extension ColumnProtocol where Self.Element : Comparable {

    /// Returns a Boolean array that indicates whether the corresponding element of a column type
    /// is less than a value.
    ///   - lhs: A column type.
    ///   - rhs: A value of the same type as the column.
    /// - Returns: A Boolean array.
    public static func < (lhs: Self, rhs: Self.Element) -> [Bool] { unimplemented() }

    /// Returns a Boolean array that indicates whether the value
    /// is less than the corresponding element of a column type.
    ///   - lhs: A value of the same type as the column.
    ///   - rhs: A column type.
    /// - Returns: A Boolean array.
    public static func < (lhs: Self.Element, rhs: Self) -> [Bool] { unimplemented() }

    /// Returns a Boolean array that indicates whether the corresponding element of a column type
    /// is less than or equal to a value.
    ///   - lhs: A column type.
    ///   - rhs: A value of the same type as the column.
    /// - Returns: A Boolean array.
    public static func <= (lhs: Self, rhs: Self.Element) -> [Bool] { unimplemented() }

    /// Returns a Boolean array that indicates whether the value
    /// is less than or equal to the corresponding element of a column type.
    ///   - lhs: A value of the same type as the column.
    ///   - rhs: A column type.
    /// - Returns: A Boolean array.
    public static func <= (lhs: Self.Element, rhs: Self) -> [Bool] { unimplemented() }

    /// Returns a Boolean array that indicates whether the corresponding element of a column type
    /// is greater than a value.
    ///   - lhs: A column type.
    ///   - rhs: A value of the same type as the column.
    /// - Returns: A Boolean array.
    public static func > (lhs: Self, rhs: Self.Element) -> [Bool] { unimplemented() }

    /// Returns a Boolean array that indicates whether the value
    /// is greater than the corresponding element of a column type.
    ///   - lhs: A value of the same type as the column.
    ///   - rhs: A column type.
    /// - Returns: A Boolean array.
    public static func > (lhs: Self.Element, rhs: Self) -> [Bool] { unimplemented() }

    /// Returns a Boolean array that indicates whether the corresponding element of a column type
    /// is greater than or equal to a value.
    ///   - lhs: A column type.
    ///   - rhs: A value of the same type as the column.
    /// - Returns: A Boolean array.
    public static func >= (lhs: Self, rhs: Self.Element) -> [Bool] { unimplemented() }

    /// Returns a Boolean array that indicates whether the value
    /// is greater than or equal to the corresponding element of a column type.
    ///   - lhs: A value of the same type as the column.
    ///   - rhs: A column type.
    /// - Returns: A Boolean array.
    public static func >= (lhs: Self.Element, rhs: Self) -> [Bool] { unimplemented() }

    /// Returns a Boolean array that indicates whether the corresponding element of a column type
    /// is equal to a value.
    ///   - lhs: A column type.
    ///   - rhs: A value of the same type as the column.
    /// - Returns: A Boolean array.
    public static func == (lhs: Self, rhs: Self.Element) -> [Bool] { unimplemented() }

    /// Returns a Boolean array that indicates whether the value
    /// is equal to the corresponding element of a column type.
    ///   - lhs: A value of the same type as the column.
    ///   - rhs: A column type.
    /// - Returns: A Boolean array.
    public static func == (lhs: Self.Element, rhs: Self) -> [Bool] { unimplemented() }

    /// Returns a Boolean array that indicates whether the corresponding element of a column type
    /// isn't equal to a value.
    ///   - lhs: A column type.
    ///   - rhs: A value of the same type as the column.
    /// - Returns: A Boolean array.
    public static func != (lhs: Self, rhs: Self.Element) -> [Bool] { unimplemented() }

    /// Returns a Boolean array that indicates whether the value
    /// isn't equal to the corresponding element of a column type.
    ///   - lhs: A value of the same type as the column.
    ///   - rhs: A column type.
    /// - Returns: A Boolean array.
    public static func != (lhs: Self.Element, rhs: Self) -> [Bool] { unimplemented() }
}

/// A collection that represents a selection of contiguous elements from a typed column.
///
/// A column slice contains only certain elements from its parent column.
/// Create a slice by using a subscript with a range.
///
/// ```swift
/// let slice = column[100 ..< 200]
/// ```
public struct ColumnSlice<WrappedElement> : OptionalColumnProtocol {

    /// The type of the column slice's elements, which is an optional type of the parent column's type.
    public typealias Element = WrappedElement?

    /// The type that represents a position in the column slice.
    public typealias Index = Int

    /// The name of the slice's parent column.
    public var name: String

    /// The underlying type of the column’s elements.
    public var wrappedElementType: Any.Type { unimplemented() }

    /// A prototype that creates type-erased columns with the same underlying type as the column slice.
    ///
    /// Use a type-erased column prototype to create new columns of the same type as the slice's parent column
    /// without explicitly knowing what type it is.
    public var prototype: AnyColumnPrototype { unimplemented() }

    /// Creates a slice with the contents of a column.
    ///
    /// - Parameter column: A column.
    public init(_ column: Column<WrappedElement>) { unimplemented() }

    /// Creates a new column by applying a transformation to every element.
    ///
    /// - Parameter transform: The transformation closure.
    public func map<T>(_ transform: (ColumnSlice<WrappedElement>.Element) throws -> T?) rethrows -> Column<T> { unimplemented() }

    /// Generates a slice that contains the elements that satisfy the predicate.
    ///
    /// - Parameter isIncluded: The filter predicate. Elements for which the predicate returns `true` are included.
    public func filter(_ isIncluded: (ColumnSlice<WrappedElement>.Element) throws -> Bool) rethrows -> DiscontiguousColumnSlice<WrappedElement> { unimplemented() }

    /// Returns a type-erased column slice.
    public func eraseToAnyColumn() -> AnyColumnSlice { unimplemented() }

    /// A type that represents the indices that are valid for subscripting the
    /// collection, in ascending order.
    public typealias Indices = Range<ColumnSlice<WrappedElement>.Index>

    /// A type that provides the collection's iteration interface and
    /// encapsulates its iteration state.
    ///
    /// By default, a collection conforms to the `Sequence` protocol by
    /// supplying `IndexingIterator` as its associated `Iterator`
    /// type.
    public typealias Iterator = IndexingIterator<ColumnSlice<WrappedElement>>

    /// A sequence that represents a contiguous subrange of the collection's
    /// elements.
    ///
    /// This associated type appears as a requirement in the `Sequence`
    /// protocol, but it is restated here with stricter constraints. In a
    /// collection, the subsequence should also conform to `Collection`.
    public typealias SubSequence = ColumnSlice<WrappedElement>
}

extension ColumnSlice where WrappedElement : Hashable {

    /// Generates a categorical summary of the column slice's elements that aren't missing.
    public func summary() -> CategoricalSummary<WrappedElement> { unimplemented() }
}

extension ColumnSlice : RandomAccessCollection, MutableCollection {

    /// The index of the initial element in the column slice.
    public var startIndex: Int { unimplemented() }

    /// The index of the final element in the column slice.
    public var endIndex: Int { unimplemented() }

    /// Returns the index immediately after an element index.
    /// - Parameter i: A valid index to an element in the column slice.
    public func index(after i: Int) -> Int { unimplemented() }

    /// Returns the index immediately before an element index.
    /// - Parameter i: A valid index to an element in the column slice.
    public func index(before i: Int) -> Int { unimplemented() }

    /// The number of elements in the column slice.
    public var count: Int { unimplemented() }

    /// Accesses an element at an index.
    ///
    /// - Parameter position: A valid index to an element in the column slice.
    public subscript(position: Int) -> ColumnSlice<WrappedElement>.Element { get { unimplemented() } set { unimplemented() } }

    /// Returns a Boolean that indicates whether the element at an index is missing.
    ///
    /// - Parameter index: An element index.
    public func isNil(at index: Int) -> Bool { unimplemented() }

    /// Accesses a contiguous range of elements.
    ///
    /// - Parameter range: A range of valid indices in the column slice.
    public subscript(range: Range<Int>) -> ColumnSlice<WrappedElement> { unimplemented() }
}

extension ColumnSlice : Equatable where WrappedElement : Equatable {

    /// Returns a Boolean that indicates whether the column slices are equal.
    /// - Parameters:
    ///   - lhs: A typed column slice.
    ///   - rhs: Another typed column slice.
    public static func == (lhs: ColumnSlice<WrappedElement>, rhs: ColumnSlice<WrappedElement>) -> Bool { unimplemented() }
}

extension ColumnSlice : Hashable where WrappedElement : Hashable {

    /// Hashes the essential components of the column slice by feeding them into a hasher.
    /// - Parameter hasher: A hasher the method uses to combine the components of the column slice.
    public func hash(into hasher: inout Hasher) { unimplemented() }

    /// Generates a discontiguous slice that contains unique elements.
    ///
    /// The method only adds the first of multiple elements with the same value
    /// --- the element with the smallest index ---
    /// to the slice.
    ///
    /// - Returns: A discontiguous column slice.
    public func distinct() -> DiscontiguousColumnSlice<WrappedElement> { unimplemented() }

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    public var hashValue: Int { unimplemented() }
}

extension ColumnSlice {

    /// Modifies a column slice by adding a value to each element.
    ///
    /// - Parameters:
    ///   - lhs: A column slice.
    ///   - rhs: A value of the same type as the column's elements.
    public static func += (lhs: inout ColumnSlice<WrappedElement>, rhs: WrappedElement) where WrappedElement : AdditiveArithmetic { unimplemented() }

    /// Modifies a column slice by subtracting a value from each element.
    ///
    /// - Parameters:
    ///   - lhs: A column slice.
    ///   - rhs: A value of the same type as the column's elements.
    public static func -= (lhs: inout ColumnSlice<WrappedElement>, rhs: WrappedElement) where WrappedElement : AdditiveArithmetic { unimplemented() }

    /// Modifies a column slice by multiplying each element by a value.
    ///
    /// - Parameters:
    ///   - lhs: A column slice.
    ///   - rhs: A value of the same type as the column's elements.
    public static func *= (lhs: inout ColumnSlice<WrappedElement>, rhs: WrappedElement) where WrappedElement : Numeric { unimplemented() }

    /// Modifies an integer column slice by dividing each element by a value.
    ///
    /// - Parameters:
    ///   - lhs: A column slice.
    ///   - rhs: A value of the same type as the column's elements.
    public static func /= (lhs: inout ColumnSlice<WrappedElement>, rhs: WrappedElement) where WrappedElement : BinaryInteger { unimplemented() }

    /// Modifies a floating-point column slice by dividing each element by a value.
    ///
    /// - Parameters:
    ///   - lhs: A column slice.
    ///   - rhs: A value of the same type as the column's elements.
    public static func /= (lhs: inout ColumnSlice<WrappedElement>, rhs: WrappedElement) where WrappedElement : FloatingPoint { unimplemented() }
}

extension ColumnSlice {

    /// Modifies a column slice by adding each value in a collection to
    /// the corresponding element in the column.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func += <C>(lhs: inout ColumnSlice<WrappedElement>, rhs: C) where WrappedElement : AdditiveArithmetic, WrappedElement == C.Element, C : Collection { unimplemented() }

    /// Modifies a column slice by adding each optional value in a collection to
    /// the corresponding element in the column.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func += <C>(lhs: inout ColumnSlice<WrappedElement>, rhs: C) where WrappedElement : AdditiveArithmetic, C : Collection, C.Element == WrappedElement? { unimplemented() }

    /// Modifies a column slice by subtracting each value in a collection from
    /// the corresponding element in the column.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func -= <C>(lhs: inout ColumnSlice<WrappedElement>, rhs: C) where WrappedElement : AdditiveArithmetic, WrappedElement == C.Element, C : Collection { unimplemented() }

    /// Modifies a column slice by subtracting each optional value in a collection from
    /// the corresponding element in the column.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func -= <C>(lhs: inout ColumnSlice<WrappedElement>, rhs: C) where WrappedElement : AdditiveArithmetic, C : Collection, C.Element == WrappedElement? { unimplemented() }

    /// Modifies a column slice by multiplying each element in the column by
    /// the corresponding value in a collection.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func *= <C>(lhs: inout ColumnSlice<WrappedElement>, rhs: C) where WrappedElement : Numeric, WrappedElement == C.Element, C : Collection { unimplemented() }

    /// Modifies a column slice by multiplying each element in the column by
    /// the corresponding optional value in a collection.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func *= <C>(lhs: inout ColumnSlice<WrappedElement>, rhs: C) where WrappedElement : Numeric, C : Collection, C.Element == WrappedElement? { unimplemented() }

    /// Modifies an integer column slice by dividing each element in the column by
    /// the corresponding value in a collection.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func /= <C>(lhs: inout ColumnSlice<WrappedElement>, rhs: C) where WrappedElement : BinaryInteger, WrappedElement == C.Element, C : Collection { unimplemented() }

    /// Modifies an integer column slice by dividing each element in the column by
    /// the corresponding optional value in a collection.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func /= <C>(lhs: inout ColumnSlice<WrappedElement>, rhs: C) where WrappedElement : BinaryInteger, C : Collection, C.Element == WrappedElement? { unimplemented() }

    /// Modifies a floating-point column slice by dividing each element in the column by
    /// the corresponding value in a collection.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func /= <C>(lhs: inout ColumnSlice<WrappedElement>, rhs: C) where WrappedElement : FloatingPoint, WrappedElement == C.Element, C : Collection { unimplemented() }

    /// Modifies a floating-point column slice by dividing each element in the column by
    /// the corresponding optional value in a collection.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func /= <C>(lhs: inout ColumnSlice<WrappedElement>, rhs: C) where WrappedElement : FloatingPoint, C : Collection, C.Element == WrappedElement? { unimplemented() }
}

extension ColumnSlice where WrappedElement : Comparable {

    /// Returns the element with the lowest value, ignoring missing elements.
    public func min() -> ColumnSlice<WrappedElement>.Element { unimplemented() }

    /// Returns the element with the highest value, ignoring missing elements.
    public func max() -> ColumnSlice<WrappedElement>.Element { unimplemented() }

    /// Returns the index of the element with the lowest value, ignoring missing elements.
    public func argmin() -> Int? { unimplemented() }

    /// Returns the index of the element with the highest value, ignoring missing elements.
    public func argmax() -> Int? { unimplemented() }
}

extension ColumnSlice where WrappedElement : AdditiveArithmetic {

    /// Returns the sum of the column slice's elements, ignoring missing elements.
    public func sum() -> WrappedElement { unimplemented() }
}

extension ColumnSlice where WrappedElement : FloatingPoint {

    /// Returns the mean average of the floating-point slice's elements, ignoring missing elements.
    public func mean() -> ColumnSlice<WrappedElement>.Element { unimplemented() }

    /// Returns the standard deviation of the floating-point column slice's elements, ignoring missing elements.
    ///
    /// - Parameter deltaDegreesOfFreedom: A nonnegative integer.
    /// The method calculates the standard deviation's divisor by subtracting this parameter from the number of
    /// non-`nil` elements (`n - deltaDegreesOfFreedom` where `n` is the number of non-`nil` elements).
    ///
    /// - Returns: The standard deviation; otherwise, `nil` if there are fewer than
    /// `deltaDegreesOfFreedom + 1` non-`nil` items in the column.
    public func standardDeviation(deltaDegreesOfFreedom: Int = 1) -> ColumnSlice<WrappedElement>.Element { unimplemented() }
}

extension ColumnSlice where WrappedElement : BinaryInteger {

    /// Returns the mean average of the integer slice's elements, ignoring missing elements.
    public func mean() -> Double? { unimplemented() }

    /// Returns the standard deviation of the integer column slice's elements, ignoring missing elements.
    ///
    /// - Parameter deltaDegreesOfFreedom: A nonnegative integer.
    /// The method calculates the standard deviation's divisor by subtracting this parameter from the number of
    /// non-`nil` elements (`n - deltaDegreesOfFreedom` where `n` is the number of non-`nil` elements).
    ///
    /// - Returns: The standard deviation; otherwise, `nil` if there are fewer than
    /// `deltaDegreesOfFreedom + 1` non-`nil` items in the column.
    public func standardDeviation(deltaDegreesOfFreedom: Int = 1) -> Double? { unimplemented() }
}

extension ColumnSlice : CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {

    /// A text representation of the column slice.
    public var description: String { unimplemented() }

    /// A text representation of the column slice suitable for debugging.
    public var debugDescription: String { unimplemented() }

    /// A mirror that reflects the column slice.
    public var customMirror: Mirror { unimplemented() }
}

extension ColumnSlice where WrappedElement : FloatingPoint {

    /// Generates a numeric summary of the floating-point column slice's elements.
    public func numericSummary() -> NumericSummary<WrappedElement> { unimplemented() }
}

extension ColumnSlice where WrappedElement : BinaryInteger {

    /// Generates a numeric summary of the integer column slice's elements.
    public func numericSummary() -> NumericSummary<Double> { unimplemented() }
}

/// Two-dimensional, size-mutable, potentially heterogeneous tabular data.
@dynamicMemberLookup public struct DataFrame : DataFrameProtocol {

    public subscript(range: Range<Int>) -> Slice {
        get {
            unimplemented()
        }
        set {
            unimplemented()
        }
    }


    /// The entire data frame as a collection of columns.
    public var columns: [AnyColumn] { unimplemented() }

    /// The entire data frame as a collection of rows.
    public var rows: DataFrame.Rows

    /// The number of rows and columns in the data frame.
    ///
    /// - Parameters:
    ///   - rows: The number of rows in the data frame.
    ///   - columns: The number of columns in the data frame.
    public var shape: (rows: Int, columns: Int) { unimplemented() }

    /// Creates an empty data frame with no rows or columns.
    public init() { unimplemented() }

    /// Creates a new data frame from a sequence of columns.
    /// - Parameter columns: A sequence of type-erased columns.
    public init<S>(columns: S) where S : Sequence, S.Element == AnyColumn { unimplemented() }

    /// Creates a new data frame with a slice of rows from another data frame.
    /// - Parameter other: A row slice from another data frame.
    public init(_ other: DataFrame.Slice) { unimplemented() }

    /// Returns the index of a column.
    ///
    /// - Parameter columnName: The name or an alias of the column.
    /// - Returns: An integer if the column name or alias exists in the data frame;
    ///   otherwise, `nil`.
    ///
    ///   This method's complexity is O(*1*).
    public func indexOfColumn(_ columnName: String) -> Int? { unimplemented() }

    /// Returns the column names for an alias.
    ///
    /// Use this method to discover whether an alias refers to more than one column.
    /// For example, a data frame may have multiple columns with the same name
    /// after you call its ``join(_:on:kind:)-1uldg`` method.
    public func columnNames(forAlias alias: String) -> [String] { unimplemented() }

    /// Adds an alternative name for a column.
    /// - Parameters:
    ///   - alias: An additional name for the column.
    ///   - columnName: The name of a column.
    public mutating func addAlias(_ alias: String, forColumn columnName: String) { unimplemented() }

    /// Removes an alternative name for a column.
    /// - Parameter alias: An additional name for the column.
    public mutating func removeAlias(_ alias: String) { unimplemented() }

    /// Adds a typed column to the end of the data frame.
    /// - Parameter column: A typed column.
    /// The column must have the same number of rows as the data frame,
    /// and must not have the same name as another column in the data frame.
    ///
    /// The column you append becomes the last column and has the highest index
    /// in the data frame.
    public mutating func append<T>(column: Column<T>) { unimplemented() }

    /// Adds a type-erased column to the end of the data frame.
    /// - Parameter column: A type-erased column.
    /// The column must have the same number of rows as the data frame,
    /// and must not have the same name as another column in the data frame.
    public mutating func append(column: AnyColumn) { unimplemented() }

    /// Adds a typed column at a position in the data frame.
    /// - Parameters:
    ///   - column: A typed column.
    ///     The column must have the same number of rows as the data frame,
    ///     and must not have the same name as another column in the data frame.
    ///
    ///   - index: A column position in the data frame.
    ///
    /// The method inserts the new column before the column currently at `index`.
    /// If you pass the array's `shape.columns` property as the `index` parameter,
    /// the method appends the new column to the data frame.
    public mutating func insert<T>(column: Column<T>, at index: Int) { unimplemented() }

    /// Adds a type-erased column at a position in the data frame.
    /// - Parameters:
    ///   - column: A type-erased column.
    ///     The column must have the same number of rows as the data frame,
    ///     and must not have the same name as another column in the data frame.
    ///
    ///   - index: A column position in the data frame.
    ///
    /// The method inserts the new column before the column currently at `index`.
    /// If you pass the array's `shape.column` property as the `index` parameter,
    /// the method appends the new column to the data frame.
    public mutating func insert(column: AnyColumn, at index: Int) { unimplemented() }

    /// Renames a column in the data frame.
    /// - Parameters:
    ///   - name: The name of a column in the data frame.
    ///   - newName: The new name for the column. The new name must not be the
    ///   same as another column in the data frame.
    public mutating func renameColumn(_ name: String, to newName: String) { unimplemented() }

    /// Replaces a column in the data frame, by name, with a type-erased column.
    /// - Parameters:
    ///   - name: The name of a column in the data frame.
    ///   - newColumn: Another column that replaces the column.
    public mutating func replaceColumn(_ name: String, with newColumn: AnyColumn) { unimplemented() }

    /// Replaces a column in the data frame, by column identifier, with a type-erased column.
    /// - Parameters:
    ///   - id: The identifier of a column in the data frame.
    ///   - newColumn: Another column that replaces the column.
    public mutating func replaceColumn<T>(_ id: ColumnID<T>, with newColumn: AnyColumn) { unimplemented() }

    /// Replaces a column in the data frame, by name, with a typed column.
    /// - Parameters:
    ///   - name: The name of a column in the data frame.
    ///   - newColumn: Another column that replaces the column.
    public mutating func replaceColumn<T>(_ name: String, with newColumn: Column<T>) { unimplemented() }

    /// Replaces a column in the data frame, by column identifier, with a typed column.
    /// - Parameters:
    ///   - id: The identifier of a column in the data frame.
    ///   - newColumn: Another column that replaces the column.
    public mutating func replaceColumn<T, U>(_ id: ColumnID<T>, with newColumn: Column<U>) { unimplemented() }

    /// Removes a column you select by its column identifier from the data frame.
    /// - Parameter id: The identifier of a column in the data frame.
    /// - Returns: The column the method removes from the data frame.
    public mutating func removeColumn<T>(_ id: ColumnID<T>) -> Column<T> { unimplemented() }

    /// Removes a column you select by its name from the data frame.
    /// - Parameter name: The name of a column in the data frame.
    /// - Returns: The column the method removes from the data frame.
    public mutating func removeColumn(_ name: String) -> AnyColumn { unimplemented() }

    /// Applies a transform closure that modifies the elements of a column you select by column identifier.
    /// - Parameters:
    ///   - id: The identifier of a column in the data frame.
    ///   - transform: A closure that transforms each element in the column.
    public mutating func transformColumn<From, To>(_ id: ColumnID<From>, _ transform: (From?) throws -> To?) rethrows { unimplemented() }

    /// Applies a transform closure that modifies the nonempty elements of a column
    /// you select by column identifier.
    /// - Parameters:
    ///   - id: The identifier of a column in the data frame.
    ///   - transform: A closure that transforms each  non-`nil` element in the column.
    public mutating func transformColumn<From, To>(_ id: ColumnID<From>, _ transform: (From) throws -> To?) rethrows { unimplemented() }

    /// Applies a transform closure that modifies the elements of a column you select by name.
    /// - Parameters:
    ///   - name: The name of a column in the data frame.
    ///   - transform: A closure that transforms each element in the column.
    public mutating func transformColumn<From, To>(_ name: String, _ transform: (From?) throws -> To?) rethrows { unimplemented() }

    /// Applies a transform closure that modifies the nonempty elements of a column you select by name.
    /// - Parameters:
    ///   - name: The name of a column in the data frame.
    ///   - transform: A closure that transforms each element in the column.
    public mutating func transformColumn<From, To>(_ name: String, _ transform: (From) throws -> To?) rethrows { unimplemented() }

    /// Adds a row of values to the data frame.
    /// - Parameter row: A row from a data frame.
    public mutating func append(row: DataFrame.Row) { unimplemented() }

    /// Adds a comma-separated, or variadic, list of values as a row to the data frame.
    /// - Parameter row: A series of optional values. The type of each value must
    /// match the type of the corresponding column.
    public mutating func append(row: Any?...) { unimplemented() }

    /// Adds a dictionary's values as a row to the data frame.
    /// - Parameter dictionary: A dictionary of values whose key is a column's name.
    /// Each key in the dictionary must be the name or alias of a column in the data frame.
    /// Each value in the dictionary must be of the same types as the corresponding column.
    public mutating func append(valuesByColumn dictionary: [String : Any?]) { unimplemented() }

    /// Adds an empty row to the data frame.
    ///
    /// Each value in an empty row is `nil`.
    public mutating func appendEmptyRow() { unimplemented() }

    /// Adds a row of values at a position in the data frame.
    /// - Parameters:
    ///   - row: A row from a data frame.
    ///   - index: A row position in the data frame.
    /// The method inserts the new row before the row currently at `index`.
    /// If you pass the array's `shape.rows` property as the `index` parameter,
    /// the method appends the new row to the data frame.
    public mutating func insert(row: DataFrame.Row, at index: Int) { unimplemented() }

    /// Removes a row from the data frame.
    /// - Parameter index: A row position in the data frame.
    public mutating func removeRow(at index: Int) { unimplemented() }

    /// Returns a slice that contains the initial rows up to a maximum length.
    ///
    /// - Parameter maxLength: The maximum number of rows.
    public func prefix(_ maxLength: Int) -> DataFrame.Slice { unimplemented() }

    /// Returns a slice that contains the final rows up to a maximum length.
    ///
    /// - Parameter maxLength: The maximum number of rows.
    public func suffix(_ maxLength: Int) -> DataFrame.Slice { unimplemented() }

    /// Adds the rows of another data frame that has the same column names and types.
    /// - Parameter other: Another data frame that has the same number of columns.
    /// The columns in `other` must have the same names and types as the columns in the data frame.
    public mutating func append(rowsOf other: DataFrame) { unimplemented() }

    /// Adds the rows of another data frame.
    /// - Parameter other: Another data frame. The columns in `other` that have
    /// the same name as columns in the data frame must also have the same type.
    ///
    /// The method ignores columns in `other` that don't exist in the data frame.
    /// The method fills the values for columns in the data frame that don't exist in `other` to `nil`.
    public mutating func append(_ other: DataFrame) { unimplemented() }

    /// Adds the rows of a slice from a data frame.
    /// - Parameter other: A slice of a data frame. The columns in `other` that have
    /// the same name as columns in the data frame must also have the same type.
    ///
    /// The method ignores columns in `other` that don't exist in the data frame.
    /// The method fills the values for columns in the data frame that don't exist in `other` to `nil`.
    public mutating func append(_ other: DataFrame.Slice) { unimplemented() }

    /// Returns a selection of rows that satisfy a predicate in the columns you select by name.
    /// - Parameters:
    ///   - columnName: The name of a column.
    ///   - type: The type of the column.
    ///   - isIncluded: A predicate closure that receives an element of the column as its argument
    ///   and returns a Boolean that indicates whether the slice includes the element's row.
    /// - Returns: A data frame slice that contains the rows that satisfy the predicate.
    public func filter<T>(on columnName: String, _ type: T.Type, _ isIncluded: (T?) throws -> Bool) rethrows -> DataFrame.Slice { unimplemented() }

    /// Returns a selection of rows that satisfy a predicate in the columns you select by column identifier.
    /// - Parameters:
    ///   - columnID: The identifier of a column in the data frame.
    ///   - isIncluded: A predicate closure that receives an element of the column as its argument
    ///   and returns a Boolean that indicates whether the slice includes the element's row.
    /// - Returns: A data frame slice that contains the rows that satisfy the predicate.
    public func filter<T>(on columnID: ColumnID<T>, _ isIncluded: (T?) throws -> Bool) rethrows -> DataFrame.Slice { unimplemented() }

    /// Returns a selection of rows that satisfy a predicate.
    /// - Parameter isIncluded: A predicate closure that receives an row and
    ///   returns a Boolean that indicates whether the slice includes that row.
    /// - Returns: A data frame slice that contains the rows that satisfy the predicate.
    public func filter(_ isIncluded: (DataFrame.Row) throws -> Bool) rethrows -> DataFrame.Slice { unimplemented() }

    /// Generates a new data frame that includes the columns you name with a sequence of names.
    /// - Parameter columnNames: A sequence of column names.
    /// - Returns: A new data frame.
    public func selecting<S>(columnNames: S) -> DataFrame where S : Sequence, S.Element == String { unimplemented() }

    /// Generates a new data frame that includes the columns you name in a comma-separated, or variadic, list.
    /// - Parameter columnNames: A series of column names.
    /// - Returns: A new data frame.
    public func selecting(columnNames: String...) -> DataFrame { unimplemented() }

    /// A type that conforms to the type-erased column protocol.
    public typealias ColumnType = AnyColumn
}

extension DataFrame {

    /// Accesses a column by its name to support dynamic-member lookup.
    /// - Parameter columnName: The name of a column.
    public subscript(dynamicMember columnName: String) -> AnyColumn { unimplemented() }

    /// Accesses a column by its name.
    /// - Parameter columnName: The name of a column.
    public subscript(columnName: String) -> AnyColumn { unimplemented() }

    /// Accesses a column by its name and type.
    /// - Parameters:
    ///   - columnName: The name of a column.
    ///   - type: The type of the column.
    public subscript<T>(columnName: String, type: T.Type) -> Column<T> { unimplemented() }

    /// Accesses a column by its column identifier.
    /// - Parameter id: The identifier of a column.
    public subscript<T>(id: ColumnID<T>) -> Column<T> { unimplemented() }

    /// Generates a new data frame that includes the columns you select by name.
    /// - Parameter columnNames: A sequence of column names.
    /// - Returns: A new data frame.
    public subscript<S>(columnNames: S) -> DataFrame where S : Sequence, S.Element == String { unimplemented() }

    /// Accesses a column by its index.
    /// - Parameter index: The index of a column.
    public subscript(column index: Int) -> AnyColumn { unimplemented() }

    /// Accesses a column by its index and type.
    /// - Parameters:
    ///   - index: The index of a column.
    ///   - type: The type of the column.
    public subscript<T>(column index: Int, type: T.Type) -> Column<T> { unimplemented() }

    /// Accesses a row by its index.
    /// - Parameter index: The index of a row.
    public subscript(row index: Int) -> DataFrame.Row { unimplemented() }

    /// Returns a slice of the rows by masking its elements with a Boolean column.
    /// - Parameter mask: A Boolean column that indicates whether the method includes a row in the slice.
    public subscript<C>(mask: C) -> DataFrame.Slice where C : Collection, C.Element == Bool { unimplemented() }
}

extension DataFrame : Hashable {

    /// Returns a Boolean that indicates whether the data frames are equal.
    /// - Parameters:
    ///   - lhs: A data frame.
    ///   - rhs: Another data frame.
    public static func == (lhs: DataFrame, rhs: DataFrame) -> Bool { unimplemented() }

    /// Hashes the essential components of the data frame by feeding them into a hasher.
    /// - Parameter hasher: A hasher the method uses to combine the components of the data frame.
    public func hash(into hasher: inout Hasher) { unimplemented() }

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    public var hashValue: Int { unimplemented() }
}

extension DataFrame : ExpressibleByDictionaryLiteral {

    /// Creates a data frame from a dictionary literal.
    ///
    /// Don't call this initializer directly.
    /// The compiler calls it to create a data frame from a dictionary literal.
    /// You create a dictionary literal by enclosing a comma-separated list of key-value pairs in square brackets.
    ///
    /// For example, this line creates a data frame with two columns and four rows:
    /// ```swift
    /// let dataFrame: DataFrame = ["a": [1, 2, 3, 5], "b": [1.414, 2.718, 3.14, 6.28]]
    /// ```
    ///
    /// - Parameter elements: One or more tuples that pair a string with an array of `Any` optionals.
    /// The data frame assigns each tuple's string to a column's name, and the array to the column's elements.
    ///
    /// The initializer checks each column's elements and, if possible, defines the column's type to one of the
    /// following:
    /// - `Bool`
    /// - `Int`
    /// - `Float`
    /// - `Double`
    /// - `Date`
    /// - `String`
    /// - `Data`
    ///
    /// Otherwise, the data frame sets a column's type to `Any`.
    ///
    /// > Note: Use ``append(column:)-aema`` to add a column of a specific type.
    public init(dictionaryLiteral elements: (String, [Any?])...) { unimplemented() }

    /// The key type of a dictionary literal.
    public typealias Key = String

    /// The value type of a dictionary literal.
    public typealias Value = [Any?]
}

extension DataFrame {

    /// A set of a data frame's rows you create by using a method from a data frame instance
    /// or another data frame slice.
    ///
    /// A slice is an arbitrary set of rows from a data frame.
    /// For example, a slice might contain rows 0–3, 5–9, and 101 from its underlying data frame.
    @dynamicMemberLookup public struct Slice : DataFrameProtocol {
        public subscript(range: Range<Int>) -> DataFrame.Slice {
            get {
                unimplemented()
            }

            set {
                unimplemented()
            }
        }


        /// The underlying data frame.
        public var base: DataFrame { unimplemented() }

        /// The entire slice as a collection of rows.
        public var rows: DataFrame.Rows

        /// The entire slice as a collection of columns.
        public var columns: [AnyColumnSlice] { unimplemented() }

        /// The number of rows and columns in the slice.
        ///
        /// - Parameters:
        ///   - rows: The number of rows in the slice.
        ///   - columns: The number of columns in the slice.
        public var shape: (rows: Int, columns: Int) { unimplemented() }

        /// A type that conforms to the type-erased column protocol.
        public typealias ColumnType = AnyColumnSlice
    }
}

extension DataFrame {

    /// Merges two columns that you select by name into a new column.
    ///
    /// - Parameters:
    ///   - columnName1: The name of a column.
    ///   - columnName2: The name of another column.
    ///   - newColumnName: The name of the new column that replaces the two columns.
    ///   - transform: A closure that combines the corresponding elements of the two columns into one element.
    ///
    ///   The merged column replaces the original column.
    public mutating func combineColumns<E1, E2, R>(_ columnName1: String, _ columnName2: String, into newColumnName: String, transform: (E1?, E2?) throws -> R?) rethrows { unimplemented() }

    /// Merges two columns that you select by column identifier into a new column.
    ///
    /// - Parameters:
    ///   - columnID1: The identifier of a column.
    ///   - columnID2: The identifier of another column.
    ///   - newColumnName: The name of the new column that replaces the two columns.
    ///   - transform: A closure that combines the corresponding elements of the two columns into one element.
    ///
    ///   The merged column replaces the original column.
    public mutating func combineColumns<E1, E2, R>(_ columnID1: ColumnID<E1>, _ columnID2: ColumnID<E2>, into newColumnName: String, transform: (E1?, E2?) throws -> R?) rethrows { unimplemented() }

    /// Merges three columns that you select by name into a new column.
    ///
    /// - Parameters:
    ///   - columnName1: The name of a column.
    ///   - columnName2: The name of a second column.
    ///   - columnName3: The name of a third column.
    ///   - newColumnName: The name of the new column that replaces the three columns.
    ///   - transform: A closure that combines the corresponding elements of the three columns into one element.
    ///
    ///   The merged column replaces the original column.
    public mutating func combineColumns<E1, E2, E3, R>(_ columnName1: String, _ columnName2: String, _ columnName3: String, into newColumnName: String, transform: (E1?, E2?, E3?) throws -> R?) rethrows { unimplemented() }

    /// Merges three columns that you select by column identifier into a new column.
    ///
    /// - Parameters:
    ///   - columnID1: The identifier of a column.
    ///   - columnID2: The identifier of a second column.
    ///   - columnID3: The identifier of a third column.
    ///   - newColumnName: The name of the new column that replaces the three columns.
    ///   - transform: A closure that combines the corresponding elements of the three columns into one element.
    ///
    ///   The merged column replaces the original column.
    public mutating func combineColumns<E1, E2, E3, R>(_ columnID1: ColumnID<E1>, _ columnID2: ColumnID<E2>, _ columnID3: ColumnID<E3>, into newColumnName: String, transform: (E1?, E2?, E3?) throws -> R?) rethrows { unimplemented() }
}

extension DataFrame {

    /// Creates a data frame from a CSV file.
    ///
    /// - Parameters:
    ///   - url: A URL for a CSV file.
    ///   - columns: An array of column names; Set to `nil` to use every column in the CSV file.
    ///   - rows: A range of indices; Set to `nil` to use every row in the CSV file.
    ///   - types: A dictionary of column names and their CSV types.
    ///   The data frame infers the types for column names that aren't in the dictionary.
    ///   - options: The options that tell the data frame how to read the CSV file.
    /// - Throws: A `CSVReadingError` instance.
    public init(contentsOfCSVFile url: URL, columns: [String]? = nil, rows: Range<Int>? = nil, types: [String : CSVType] = [:], options: CSVReadingOptions = .init()) throws { unimplemented() }

    /// Creates a data frame from CSV file data.
    ///
    /// - Parameters:
    ///   - data: The contents of a CSV file in a
    ///   <doc://com.apple.documentation/documentation/Foundation/Data> instance.
    ///   - columns: An array of column names; Set to `nil` to use every column in the CSV file.
    ///   - rows: A range of indices; Set to `nil` to use every row in the CSV file.
    ///   - types: A dictionary of column names and their CSV types.
    ///   The data frame infers the types for column names that aren't in the dictionary.
    ///   - options: The options that tell the data frame how to read the CSV data.
    /// - Throws: A `CSVReadingError` instance.
    public init(csvData data: Data, columns: [String]? = nil, rows: Range<Int>? = nil, types: [String : CSVType] = [:], options: CSVReadingOptions = .init()) throws { unimplemented() }
}

extension DataFrame {

    /// The underlying data frame.
    ///
    /// For a ``DataFrame`` instance, this property is equivalent to `self`.
    public var base: DataFrame { unimplemented() }
}

extension DataFrame {

    /// Arranges the rows of a data frame according to a column that you select by its name.
    /// - Parameters:
    ///   - columnName: The name of a column.
    ///   - order: A sorting order.
    ///
    /// This is a convenience method that only works for columns of the following types:
    /// - <doc://com.apple.documentation/documentation/Swift/Bool>
    /// - <doc://com.apple.documentation/documentation/Swift/Int>
    /// - <doc://com.apple.documentation/documentation/Swift/Float>
    /// - <doc://com.apple.documentation/documentation/Swift/Double>
    /// - <doc://com.apple.documentation/documentation/Foundation/Date>
    ///
    /// > Note: Elements with a value of `nil` are less than all non-`nil` values.
    public mutating func sort(on columnName: String, order: Order = .ascending) { unimplemented() }

    /// Arranges the rows of a data frame according to a column that you select by its name and type.
    /// - Parameters:
    ///   - columnName: The name of a column.
    ///   - type: The column's type.
    ///   - order: A sorting order.
    /// > Note: Elements with a value of `nil` are less than all non-`nil` values.
    public mutating func sort<T>(on columnName: String, _ type: T.Type, order: Order = .ascending) where T : Comparable { unimplemented() }

    /// Arranges the rows of a data frame according to a column that you select by its column identifier.
    /// - Parameters:
    ///   - columnID0: The identifier of a column.
    ///   - order: A sorting order.
    /// > Note: Elements with a value of `nil` are less than all non-`nil` values.
    public mutating func sort<T>(on columnID: ColumnID<T>, order: Order = .ascending) where T : Comparable { unimplemented() }

    /// Arranges the rows of a data frame according to two columns that you select by their column identifiers.
    /// - Parameters:
    ///   - columnID0: The identifier of a column.
    ///   - columnID1: The identifier of another column.
    ///   - order: A sorting order.
    /// > Note: Elements with a value of `nil` are less than all non-`nil` values.
    public mutating func sort<T0, T1>(on columnID0: ColumnID<T0>, _ columnID1: ColumnID<T1>, order: Order = .ascending) where T0 : Comparable, T1 : Comparable { unimplemented() }

    /// Arranges the rows of a data frame according to three columns that you select by their column identifiers.
    /// - Parameters:
    ///   - columnID0: The identifier of a column.
    ///   - columnID1: The identifier of a second column.
    ///   - columnID2: The identifier of a third column.
    ///   - order: A sorting order.
    /// > Note: Elements with a value of `nil` are less than all non-`nil` values.
    public mutating func sort<T0, T1, T2>(on columnID0: ColumnID<T0>, _ columnID1: ColumnID<T1>, _ columnID2: ColumnID<T2>, order: Order = .ascending) where T0 : Comparable, T1 : Comparable, T2 : Comparable { unimplemented() }

    /// Arranges the rows of a data frame according to a column that you select by its column identifier,
    /// with a predicate.
    /// - Parameters:
    ///   - columnID: The identifier of a column.
    ///   - areInIncreasingOrder: A closure that returns a Boolean that indicates
    ///   whether the two elements are in increasing order.
    /// > Note: Elements with a value of `nil` are less than all non-`nil` values.
    public mutating func sort<T>(on columnID: ColumnID<T>, by areInIncreasingOrder: (T, T) throws -> Bool) rethrows { unimplemented() }

    /// Arranges the rows of a data frame according to a column that you select by its name and type,
    /// with a predicate.
    /// - Parameters:
    ///   - columnName: The name of a column.
    ///   - type: The column's type.
    ///   - areInIncreasingOrder: A closure that returns a Boolean that indicates
    ///   whether the two elements are in increasing order.
    /// > Note: Elements with a value of `nil` are less than all non-`nil` values.
    public mutating func sort<T>(on columnName: String, _ type: T.Type, by areInIncreasingOrder: (T, T) throws -> Bool) rethrows { unimplemented() }
}

extension DataFrame : CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {

    /// A text representation of the data frame.
    public var description: String { unimplemented() }

    /// A text representation of the data frame suitable for debugging.
    public var debugDescription: String { unimplemented() }

    /// A mirror that reflects the data frame.
    public var customMirror: Mirror { unimplemented() }
}

extension DataFrame {

    /// A single row within a data frame.
    public struct Row {

        /// The row's underlying data frame.
        public var base: DataFrame { unimplemented() }

        /// The row's index in the underlying data frame.
        public let index: Int

        /// Accesses a value in the row you select by a column index and type.
        /// - Parameters:
        ///   - position: A valid column index in the row.
        ///   - type: The type of the column.
        public subscript<T>(position: Int, type: T.Type) -> T? { unimplemented() }

        /// Accesses a value in the row you select by a column name and type.
        /// - Parameters:
        ///   - columnName: The name of a column.
        ///   - type: The type of the column.
        public subscript<T>(columnName: String, type: T.Type) -> T? { unimplemented() }

        /// Accesses a value in the row you select by a column name.
        /// - Parameter columnName: The name of a column.
        public subscript(columnName: String) -> Any? { unimplemented() }

        /// Accesses a value in the row you select by a column identifier.
        /// - Parameter columnID: The identifier of a column.
        public subscript<T>(columnID: ColumnID<T>) -> T? { unimplemented() }
    }
}

extension DataFrame {

    /// Creates a data frame by reading a JSON file.
    ///
    /// - Parameters:
    ///   - url: A URL to a JSON file.
    ///   - columns: An array of column names; Set to `nil` to use every column in the JSON file.
    ///   - types: A dictionary of column names and their JSON types.
    ///   The data frame infers the types for column names that aren't in the dictionary.
    ///   - options: The options that instruct how the data frame reads the JSON file.
    /// - Throws: A `JSONReadingError` instance.
    public init(contentsOfJSONFile url: URL, columns: [String]? = nil, types: [String : JSONType] = [:], options: JSONReadingOptions = .init()) throws { unimplemented() }

    /// Creates a data frame by converting JSON data.
    ///
    /// - Parameters:
    ///   - data: The contents of a JSON file as data.
    ///   - columns: An array of column names; Set to `nil` to use every column in the JSON file.
    ///   - types: A dictionary of column names and their JSON types.
    ///   The data frame infers the types for column names that aren't in the dictionary.
    ///   - options: The options that instruct how the data frame reads the JSON file.
    /// - Throws: A `JSONReadingError` instance.
    public init(jsonData data: Data, columns: [String]? = nil, types: [String : JSONType] = [:], options: JSONReadingOptions = .init()) throws { unimplemented() }
}

extension DataFrame {

    /// Replaces each row in a collection column that you select by column identifier,
    /// with a new row for each element in the original row's collection.
    ///
    /// - Parameter id: A column identifier.
    public mutating func explodeColumn<T>(_ id: ColumnID<T>) where T : Collection { unimplemented() }

    /// Replaces each row in a collection column that you select by name,
    /// with a new row for each element in the original row's collection.
    ///
    /// - Parameter name: A column name.
    public mutating func explodeColumn<T>(_ name: String, _ type: T.Type) where T : Collection { unimplemented() }

    /// Generates a new data frame by replacing each row in a collection column that you select by name,
    /// with a new row for each element in the original row's collection.
    ///
    /// - Parameters:
    ///   - name: A column name.
    ///   - type: The underlying type of the column.
    public func explodingColumn<T>(_ name: String, _ type: T.Type) -> DataFrame where T : Collection { unimplemented() }

    /// Generates a new data frame by replacing each row in a collection column that you select by column identifier,
    /// with a new row for each element in the original row's collection.
    ///
    /// - Parameter id: A column identifier.
    public func explodingColumn<T>(_ id: ColumnID<T>) -> DataFrame where T : Collection { unimplemented() }
}

extension DataFrame {

    /// Creates a data frame from a Turi Create scalable data frame.
    ///
    /// - Parameters:
    ///   - url: A URL to an `SFrame` directory.
    ///   - columns: An array of column names; Set to `nil` to use every column in the `SFrame`.
    ///   - rows: A range of indices; Set to `nil` to use every row in the `SFrame`.
    /// - Throws: An `SFrameReadingError` instance.
    public init(contentsOfSFrameDirectory url: URL, columns: [String]? = nil, rows: Range<Int>? = nil) throws { unimplemented() }
}

extension DataFrame {

    /// Generates a data frame with a single row that summarizes the columns of the data frame.
    public func summaryOfAllColumns() -> DataFrame { unimplemented() }

    /// Generates a data frame with a single row that summarizes the columns you select by name.
    ///
    /// - Parameter columnNames: A comma-separated, or variadic, list of column names in the data frame.
    public func summary(of columnNames: String...) -> DataFrame { unimplemented() }

    /// Generates a data frame with a single row that summarizes the columns you select by index.
    ///
    /// - Parameter columnIndices: A comma-separated, or variadic, list of column indices in the data frame.
    public func summary(of columnIndices: Int...) -> DataFrame { unimplemented() }

    /// Generates a data frame with a single row that numerically summarizes the columns you select by name.
    /// - Parameter columnNames: A comma-separated, or variadic, list of column names in the data frame.
    public func numericSummary(of columnNames: String...) -> DataFrame { unimplemented() }

    /// Generates a data frame with a single row that numerically summarizes the columns you select by index.
    /// - Parameter columnIndices: A comma-separated, or variadic, list of column indices in the data frame.
    public func numericSummary(ofColumns columnIndices: Int...) -> DataFrame { unimplemented() }
}

extension DataFrame {

    /// A collection of rows in a data frame.
    public struct Rows : BidirectionalCollection, MutableCollection {

        /// The index of the initial row in the collection.
        public var startIndex: Int { unimplemented() }

        /// The index of the final row in the collection.
        public var endIndex: Int { unimplemented() }

        /// The number of rows in the collection.
        public var count: Int { unimplemented() }

        /// Returns the row index immediately after a row index.
        /// - Parameter i: A valid index to a row in the collection.
        public func index(after i: Int) -> Int { unimplemented() }

        /// Returns the row index immediately before a row index.
        /// - Parameter i: A valid index to a row in the collection.
        public func index(before i: Int) -> Int { unimplemented() }

        /// Accesses a row at an index.
        /// - Parameter position: A valid index to a row in the collection.
        public subscript(position: Int) -> DataFrame.Row { get { unimplemented() } set { unimplemented() } }

        /// Returns a row collection from an index range.
        /// - Parameter position: A valid index to a row in the collection.
        public subscript(bounds: Range<Int>) -> DataFrame.Rows { unimplemented() }

        /// A type representing the sequence's elements.
        public typealias Element = DataFrame.Row

        /// A type that represents a position in the collection.
        ///
        /// Valid indices consist of the position of every element and a
        /// "past the end" position that's not valid for use as a subscript
        /// argument.
        public typealias Index = Int

        /// A type that represents the indices that are valid for subscripting the
        /// collection, in ascending order.
        public typealias Indices = DefaultIndices<DataFrame.Rows>

        /// A type that provides the collection's iteration interface and
        /// encapsulates its iteration state.
        ///
        /// By default, a collection conforms to the `Sequence` protocol by
        /// supplying `IndexingIterator` as its associated `Iterator`
        /// type.
        public typealias Iterator = IndexingIterator<DataFrame.Rows>

        /// A sequence that represents a contiguous subrange of the collection's
        /// elements.
        ///
        /// This associated type appears as a requirement in the `Sequence`
        /// protocol, but it is restated here with stricter constraints. In a
        /// collection, the subsequence should also conform to `Collection`.
        public typealias SubSequence = DataFrame.Rows
    }
}

extension DataFrame {

    /// Creates a grouping of rows that the method selects
    /// by choosing unique values in a column.
    /// - Parameter columnName: The name of a column.
    public func grouped(by columnName: String) -> RowGroupingProtocol { unimplemented() }
}

extension DataFrame.Slice {

    /// Returns a column you select by its name to support dynamic-member lookup.
    /// - Parameter columnName: The name of a column.
    public subscript(dynamicMember columnName: String) -> AnyColumnSlice { unimplemented() }

    /// Returns a column you select by its name.
    /// - Parameter columnName: The name of a column.
    public subscript(columnName: String) -> AnyColumnSlice { unimplemented() }

    /// Returns a column you select by its name and type.
    /// - Parameters:
    ///   - columnName: The name of a column.
    ///   - type: The type of the column.
    public subscript<T>(columnName: String, type: T.Type) -> DiscontiguousColumnSlice<T> { unimplemented() }

    /// Returns a column you select by its column identifier.
    /// - Parameter id: The identifier of a column.
    public subscript<T>(columnID: ColumnID<T>) -> DiscontiguousColumnSlice<T> { unimplemented() }

    /// Returns a column you select by its index.
    /// - Parameter index: The index of a column.
    public subscript<T>(column index: Int, type: T.Type) -> DiscontiguousColumnSlice<T> { unimplemented() }

    /// Returns a selection of rows that satisfy a predicate in the columns you select by name.
    /// - Parameters:
    ///   - columnName: The name of a column.
    ///   - type: The type of the column.
    ///   - isIncluded: A predicate closure that receives an element of the column as its argument,
    ///   and returns a Boolean that indicates whether the slice includes the element's row.
    /// - Returns: A data frame slice that contains the rows that satisfy the predicate.
    public func filter<T>(on columnName: String, _ type: T.Type, _ isIncluded: (T?) throws -> Bool) rethrows -> DataFrame.Slice { unimplemented() }

    /// Returns a selection of rows that satisfy a predicate in the columns you select by column identifier.
    /// - Parameters:
    ///   - columnID: The identifier of a column in the slice.
    ///   - isIncluded: A predicate closure that receives an element of the column as its argument,
    ///   and returns a Boolean that indicates whether the slice includes the element's row.
    /// - Returns: A data frame slice that contains the rows that satisfy the predicate.
    public func filter<T>(on columnID: ColumnID<T>, _ isIncluded: (T?) throws -> Bool) rethrows -> DataFrame.Slice { unimplemented() }

    /// Returns a new slice that contains the initial elements of the original slice.
    ///
    /// - Parameter length: The number of elements in the new slice.
    /// The length must be greater than or equal to zero and less than or equal to the number of elements
    /// in the original slice.
    ///
    /// - Returns: A new slice of the underlying data frame.
    public func prefix(_ length: Int) -> DataFrame.Slice { unimplemented() }

    /// Returns a new slice that contains the initial elements of the original slice
    /// up to and including the element at a position.
    ///
    /// - Parameter position: A valid index to an element in the slice.
    ///
    /// - Returns: A new slice of the underlying data frame.
    public func prefix(through position: Int) -> DataFrame.Slice { unimplemented() }

    /// Returns a new slice that contains the initial elements of the original slice
    /// up to, but not including, the element at a position.
    ///
    /// - Parameter position: A valid index to an element in the slice.
    ///
    /// - Returns: A new slice of the underlying data frame.
    public func prefix(upTo position: Int) -> DataFrame.Slice { unimplemented() }

    /// Returns a new slice that contains the final elements of the original slice.
    ///
    /// - Parameter length: The number of elements in the new slice.
    /// The length must be greater than or equal to zero and less than or equal to the number of elements
    /// in the original slice.
    ///
    /// - Returns: A new slice of the underlying data frame.
    public func suffix(_ length: Int) -> DataFrame.Slice { unimplemented() }

    /// Returns a new slice that contains the final elements of the original slice
    /// beginning with the element at a position.
    ///
    /// - Parameter position: A valid index to an element in the slice.
    ///
    /// - Returns: A new slice of the underlying data frame.
    public func suffix(from position: Int) -> DataFrame.Slice { unimplemented() }
}

extension DataFrame.Slice : Hashable {

    /// Returns a Boolean that indicates whether the slices are equal.
    ///
    /// - Parameters:
    ///   - lhs: A data frame slice.
    ///   - rhs: Another data frame slice.
    public static func == (lhs: DataFrame.Slice, rhs: DataFrame.Slice) -> Bool { unimplemented() }

    /// Hashes the essential components of the data frame slice by feeding them into a hasher.
    /// - Parameter hasher: A hasher the method uses to combine the components of the slice.
    public func hash(into hasher: inout Hasher) { unimplemented() }

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    public var hashValue: Int { unimplemented() }
}

extension DataFrame.Slice : CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {

    /// A text representation of the data frame slice.
    public var description: String { unimplemented() }

    /// A text representation of the data frame slice suitable for debugging.
    public var debugDescription: String { unimplemented() }

    /// A mirror that reflects the data frame slice.
    public var customMirror: Mirror { unimplemented() }
}

extension DataFrame.Slice {

    /// Generates a data frame with a single row that summarizes the columns of the data frame slice.
    public func summaryOfAllColumns() -> DataFrame { unimplemented() }

    /// Generates a data frame with a single row that summarizes the columns you select by name.
    ///
    /// - Parameter columnNames: A comma-separated, or variadic, list of column names in the data frame slice.
    public func summary(of columnNames: String...) -> DataFrame { unimplemented() }

    /// Generates a data frame with a single row that summarizes the columns you select by index.
    ///
    /// - Parameter columnIndices: A comma-separated, or variadic, list of column indices in the data frame slice.
    public func summary(of columnIndices: Int...) -> DataFrame { unimplemented() }

    /// Generates a data frame with a single row that numerically summarizes the columns you select by name.
    /// - Parameter columnNames: A comma-separated, or variadic, list of column names in the data frame slice.
    public func numericSummary(of columnNames: String...) -> DataFrame { unimplemented() }

    /// Generates a data frame with a single row that numerically summarizes the columns you select by name.
    /// - Parameter columnNames: A comma-separated, or variadic, list of column indices in the data frame slice.
    public func numericSummary(ofColumns columnIndices: Int...) -> DataFrame { unimplemented() }
}

extension DataFrame.Slice {

    /// Creates a grouping of rows that the method selects
    /// by choosing unique values in a column.
    /// - Parameter columnName: The name of a column.
    public func grouped(by columnName: String) -> RowGroupingProtocol { unimplemented() }
}

extension DataFrame.Row : CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {

    /// A text representation of the row.
    public var description: String { unimplemented() }

    /// A text representation of the row suitable for debugging.
    public var debugDescription: String { unimplemented() }

    /// A mirror that reflects the row.
    public var customMirror: Mirror { unimplemented() }
}

extension DataFrame.Row : RandomAccessCollection, MutableCollection {

    /// The index of the initial column in the row.
    public var startIndex: Int { unimplemented() }

    /// The index of the final column in the row.
    public var endIndex: Int { unimplemented() }

    /// Returns the column index immediately before a column index in the row.
    /// - Parameter i: A valid column index to a value in the row.
    public func index(after i: Int) -> Int { unimplemented() }

    /// Returns the column index immediately after a column index in the row.
    /// - Parameter i: A valid column index to a value in the row.
    public func index(before i: Int) -> Int { unimplemented() }

    /// The number of columns in the row.
    public var count: Int { unimplemented() }

    /// Accesses a value at a column index.
    /// - Parameter position: A valid index to a column in the row.
    public subscript(position: Int) -> Any? { get { unimplemented() } set { unimplemented() } }

    /// A type representing the sequence's elements.
    public typealias Element = Any?

    /// A type that represents a position in the collection.
    ///
    /// Valid indices consist of the position of every element and a
    /// "past the end" position that's not valid for use as a subscript
    /// argument.
    public typealias Index = Int

    /// A type that represents the indices that are valid for subscripting the
    /// collection, in ascending order.
    public typealias Indices = Range<Int>

    /// A type that provides the collection's iteration interface and
    /// encapsulates its iteration state.
    ///
    /// By default, a collection conforms to the `Sequence` protocol by
    /// supplying `IndexingIterator` as its associated `Iterator`
    /// type.
    public typealias Iterator = IndexingIterator<DataFrame.Row>

    /// A sequence that represents a contiguous subrange of the collection's
    /// elements.
    ///
    /// This associated type appears as a requirement in the `Sequence`
    /// protocol, but it is restated here with stricter constraints. In a
    /// collection, the subsequence should also conform to `Collection`.
    public typealias SubSequence = Slice<DataFrame.Row>
}

extension DataFrame.Row : Hashable {

    /// Returns a Boolean that indicates whether the rows are equal.
    /// - Parameters:
    ///   - lhs: A row.
    ///   - rhs: Another row.
    public static func == (lhs: DataFrame.Row, rhs: DataFrame.Row) -> Bool { unimplemented() }

    /// Hashes the essential components of the row by feeding them into a hasher.
    /// - Parameter hasher: A hasher the method uses to combine the components of the row.
    public func hash(into hasher: inout Hasher) { unimplemented() }

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    public var hashValue: Int { unimplemented() }
}

extension DataFrameProtocol {

    /// Generates two data frame slices by randomly splitting the rows of the data table.
    /// - Parameters:
    ///   - proportion: A proportion in the range `[0.0, 1.0]`.
    ///   - seed: A seed number for a random-number generator.
    /// - Returns: A tuple of two data frame slices.
    public func randomSplit(by proportion: Double, seed: Int? = nil) -> (DataFrame.Slice, DataFrame.Slice) { unimplemented() }

    /// Generates two data frame slices by randomly splitting the rows of the data table type
    /// with a random-number generator.
    /// - Parameters:
    ///   - proportion: A proportion in the range `[0.0, 1.0]`.
    ///   - generator: A random-number generator.
    /// - Returns: A tuple of two data frame slices.
    public func randomSplit<G>(by proportion: Double, using generator: inout G) -> (DataFrame.Slice, DataFrame.Slice) where G : RandomNumberGenerator { unimplemented() }

    /// Generates two data frames by randomly splitting the rows of a column,
    /// which you select by its name, into strata.
    ///
    /// - Parameters:
    ///   - columnName: The name of a column in the data frame type.
    ///   - proportion: A proportion in the range `[0.0, 1.0]`.
    ///   - randomSeed: A seed number for a random-number generator.
    ///
    /// - Returns: A tuple of two data frames.
    public func stratifiedSplit(on columnName: String, by proportion: Double, randomSeed: Int? = nil) -> (DataFrame, DataFrame) { unimplemented() }

    /// Generates two data frames by randomly splitting the rows of multiple columns,
    /// which you select by their names, into strata.
    ///
    /// - Parameters:
    ///   - columnNames: A comma-separated, or variadic, list of column names.
    ///   - proportion: A proportion in the range `[0.0, 1.0]`.
    ///   - randomSeed: A seed number for a random-number generator.
    ///
    /// - Returns: A tuple of two data frames.
    public func stratifiedSplit(on columnNames: String..., by proportion: Double, randomSeed: Int? = nil) -> (DataFrame, DataFrame) { unimplemented() }

    /// Generates two data frames by randomly splitting the rows of a column,
    /// which you select by column identifier,
    /// into strata.
    ///
    /// - Parameters:
    ///   - columnID: A column identifier.
    ///   - proportion: A proportion in the range `[0.0, 1.0]`.
    ///   - randomSeed: A seed number for a random-number generator.
    ///
    /// - Returns: A tuple of two data frames.
    public func stratifiedSplit<T>(on columnID: ColumnID<T>, by proportion: Double, randomSeed: Int? = nil) -> (DataFrame, DataFrame) where T : Hashable { unimplemented() }

    /// Generates two data frames by randomly splitting the rows of two columns, which you select by column identifiers,
    /// into strata.
    ///
    /// - Parameters:
    ///   - columnID0: A column identifier.
    ///   - columnID1: Another column identifier.
    ///   - proportion: A proportion in the range `[0.0, 1.0]`.
    ///   - randomSeed: A seed number for a random-number generator.
    ///
    /// - Returns: A tuple of two data frames.
    public func stratifiedSplit<T0, T1>(on columnID0: ColumnID<T0>, _ columnID1: ColumnID<T1>, by proportion: Double, randomSeed: Int? = nil) -> (DataFrame, DataFrame) where T0 : Hashable, T1 : Hashable { unimplemented() }

    /// Generates two data frames by randomly splitting the rows of three columns,
    /// which you select by column identifiers, into strata.
    ///
    /// - Parameters:
    ///   - columnID0: A column identifier.
    ///   - columnID1: A second column identifier.
    ///   - columnID2: A third column identifier.
    ///   - proportion: A proportion in the range `[0.0, 1.0]`.
    ///   - randomSeed: A seed number for a random-number generator.
    ///
    /// - Returns: A tuple of two data frames.
    public func stratifiedSplit<T0, T1, T2>(on columnID0: ColumnID<T0>, _ columnID1: ColumnID<T1>, _ columnID2: ColumnID<T2>, by proportion: Double, randomSeed: Int? = nil) -> (DataFrame, DataFrame) where T0 : Hashable, T1 : Hashable, T2 : Hashable { unimplemented() }
}

extension DataFrameProtocol {

    /// Creates a CSV file with the contents of the data frame type.
    ///
    /// - Parameters:
    ///   - url: A location URL in the file system where the method saves the CSV file.
    ///   - options: A ``CSVWritingOptions`` instance.
    public func writeCSV(to url: URL, options: CSVWritingOptions = .init()) throws { unimplemented() }

    /// Generates a CSV data instance of the data frame type.
    ///
    /// - Parameters:
    ///   - options: A ``CSVWritingOptions`` instance.
    public func csvRepresentation(options: CSVWritingOptions = .init()) throws -> Data { unimplemented() }
}

extension DataFrameProtocol {

    /// A Boolean that indicates whether the data frame type is empty.
    public var isEmpty: Bool { unimplemented() }

    /// Accesses a slice of the data frame type with an index range.
    ///
    /// - Parameter range: An integer range.
    public subscript(range: Range<Int>) -> DataFrame.Slice { unimplemented() }

    /// Accesses rows of a data frame type with an index range expression.
    ///
    /// - Parameter r: An integer range expression.
    @inlinable public subscript<R>(r: R) -> DataFrame.Slice where R : RangeExpression, R.Bound == Int { unimplemented() }
}

extension DataFrameProtocol {

    /// Generates a data frame by copying the data frame's rows and then sorting the rows according to a column
    /// that you select by its name.
    /// - Parameters:
    ///   - columnName: The name of a column.
    ///   - order: A sorting order.
    ///
    /// This is a convenience method that only works for columns of the following types:
    /// - <doc://com.apple.documentation/documentation/Swift/Bool>
    /// - <doc://com.apple.documentation/documentation/Swift/Int>
    /// - <doc://com.apple.documentation/documentation/Swift/Float>
    /// - <doc://com.apple.documentation/documentation/Swift/Double>
    /// - <doc://com.apple.documentation/documentation/Foundation/Date>
    ///
    /// > Note: Elements with a value of `nil` are less than all non-`nil` values.
    public func sorted(on columnName: String, order: Order = .ascending) -> DataFrame { unimplemented() }

    /// Generates a data frame by copying the data frame's rows and then sorting the rows according to a column
    /// that you select by its name and type.
    /// - Parameters:
    ///   - columnName: The name of a column.
    ///   - type: The column's type.
    ///   - order: A sorting order.
    /// > Note: Elements with a value of `nil` are less than all non-`nil` values.
    public func sorted<T>(on columnName: String, _ type: T.Type, order: Order = .ascending) -> DataFrame where T : Comparable { unimplemented() }

    /// Generates a data frame by copying the data frame's rows and then sorting the rows according to a column
    /// that you select by its column identifier.
    /// - Parameters:
    ///   - columnID0: The identifier of a column.
    ///   - order: A sorting order.
    /// > Note: Elements with a value of `nil` are less than all non-`nil` values.
    public func sorted<T>(on columnID: ColumnID<T>, order: Order = .ascending) -> DataFrame where T : Comparable { unimplemented() }

    /// Generates a data frame by copying the data frame's rows and then sorting the rows according to two columns
    /// that you select by their column identifiers.
    /// - Parameters:
    ///   - columnID0: The identifier of a column.
    ///   - columnID1: The identifier of another column.
    ///   - order: A sorting order.
    /// > Note: Elements with a value of `nil` are less than all non-`nil` values.
    public func sorted<T0, T1>(on columnID0: ColumnID<T0>, _ columnID1: ColumnID<T1>, order: Order = .ascending) -> DataFrame where T0 : Comparable, T1 : Comparable { unimplemented() }

    /// Generates a data frame by copying the data frame's rows and then sorting the rows according to three columns
    /// that you select by their column identifiers.
    /// - Parameters:
    ///   - columnID0: The identifier of a column.
    ///   - columnID1: The identifier of a second column.
    ///   - columnID2: The identifier of a third column.
    ///   - order: A sorting order.
    /// > Note: Elements with a value of `nil` are less than all non-`nil` values.
    public func sorted<T0, T1, T2>(on columnID0: ColumnID<T0>, _ columnID1: ColumnID<T1>, _ columnID2: ColumnID<T2>, order: Order = .ascending) -> DataFrame where T0 : Comparable, T1 : Comparable, T2 : Comparable { unimplemented() }

    /// Generates a data frame by copying the data frame's rows and then sorting the rows according to a column
    /// that you select by its name and type, with a predicate.
    /// - Parameters:
    ///   - columnName: The name of a column.
    ///   - type: The column's type.
    ///   - areInIncreasingOrder: A closure that returns a Boolean that indicates
    ///   whether the two elements are in increasing order.
    /// > Note: Elements with a value of `nil` are less than all non-`nil` values.
    public func sorted<T>(on columnName: String, _ type: T.Type, by areInIncreasingOrder: (T, T) throws -> Bool) rethrows -> DataFrame { unimplemented() }

    /// Generates a data frame by copying the data frame's rows and then sorting the rows according to a column
    /// that you select by its column identifier, with a predicate.
    /// - Parameters:
    ///   - columnID: The identifier of a column.
    ///   - areInIncreasingOrder: A closure that returns a Boolean that indicates
    ///   whether the two elements are in increasing order.
    /// > Note: Elements with a value of `nil` are less than all non-`nil` values.
    public func sorted<T>(on columnID: ColumnID<T>, by areInIncreasingOrder: (T, T) throws -> Bool) rethrows -> DataFrame { unimplemented() }
}

extension DataFrameProtocol {

    /// Generates a text representation of the data frame type.
    ///
    /// `FormattingOptions.maximumLineWidth` needs to be wide enough to print at least the index column, the truncation
    /// column, and one data column (at least two characters, one for initial of the content, and one for "…").
    ///
    /// - Parameter options: A set of formatting options that affect the description string,
    /// including the maximum width of a column and the maximum number of rows.
    public func description(options: FormattingOptions) -> String { unimplemented() }
}

extension DataFrameProtocol {

    /// Creates a grouping of rows that the method selects
    /// by choosing unique values in a column.
    /// - Parameter columnID: A column identifier.
    ///
    /// - Returns: A collection of groups.
    public func grouped<GroupingKey>(by columnID: ColumnID<GroupingKey>) -> RowGrouping<GroupingKey> where GroupingKey : Hashable { unimplemented() }

    /// Creates a grouping of rows that the method selects
    /// by choosing unique values the transform closure creates with elements of a
    /// column you select by name.
    ///
    /// Create groupings that group rows by:
    /// * Telephone area codes
    /// * The first letter of a person's last name
    /// * A date's year or quarter
    /// * Number ranges
    ///
    /// - Parameters:
    ///   - columnName: The name of a column.
    ///   - transform: A closure that transforms a column's elements into a hashable type.
    ///
    /// - Returns: A collection of groups.
    public func grouped<InputKey, GroupingKey>(by columnName: String, transform: (InputKey?) -> GroupingKey?) -> RowGrouping<GroupingKey> where GroupingKey : Hashable { unimplemented() }

    /// Creates a grouping of rows that the method selects
    /// by choosing unique values the transform closure creates with elements of a
    /// column you select by column identifier.
    ///
    /// Create groupings that group rows by:
    /// * Telephone area codes
    /// * The first letter of a person's last name
    /// * A date's year or quarter
    /// * Number ranges
    ///
    /// - Parameters:
    ///   - columnID: A column identifier.
    ///   - transform: A closure that transforms a column's elements into a hashable type.
    ///
    /// - Returns: A collection of groups.
    public func grouped<InputKey, GroupingKey>(by columnID: ColumnID<InputKey>, transform: (InputKey?) -> GroupingKey?) -> RowGrouping<GroupingKey> where GroupingKey : Hashable { unimplemented() }

    /// Creates a grouping of rows that the method selects
    /// by choosing unique units of time in a date column you select by name.
    ///
    /// - Parameters:
    ///   - columnName: The name of a column.
    ///   - timeUnit: A component of a calendar date.
    ///
    /// - Returns: A collection of groups.
    ///
    /// After the method aggregates the groups, it creates a column with the same name as the original column
    /// plus the `timeUnit` name.
    public func grouped(by columnName: String, timeUnit: Calendar.Component) -> RowGrouping<Int> { unimplemented() }

    /// Creates a grouping of rows that the method selects
    /// by choosing unique units of time in a date column you select by column identifier.
    ///
    /// - Parameters:
    ///   - columnID: A column identifier.
    ///   - timeUnit: A component of a calendar date.
    ///
    /// - Returns: A collection of groups.
    ///
    /// After the method aggregates the groups, it creates a column with the same name as the original column
    /// plus the `timeUnit` name.
    public func grouped(by columnID: ColumnID<Date>, timeUnit: Calendar.Component) -> RowGrouping<Int> { unimplemented() }

    /// Creates a grouping from multiple columns you select by name.
    ///
    /// - Parameters:
    ///   - columnNames: A comma-separated, or variadic, list of column names.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func grouped(by columnNames: String...) -> some RowGroupingProtocol { return unimplemented() }


    /// Creates a grouping from multiple columns that you select by column identifier.
    ///
    /// - Parameters:
    ///   - columnIDs: A comma-separated, or variadic, list of column identifiers.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func grouped<T>(by columnIDs: ColumnID<T>...) -> some RowGroupingProtocol where T : Hashable { return unimplemented() }


    /// Creates a grouping from two columns of different types.
    ///
    /// - Parameters:
    ///   - column0: A column identifier.
    ///   - column1: A second column identifier.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func grouped<T0, T1>(by column0: ColumnID<T0>, _ column1: ColumnID<T1>) -> some RowGroupingProtocol where T0 : Hashable, T1 : Hashable { return unimplemented() }


    /// Creates a grouping from three columns of different types.
    ///
    /// - Parameters:
    ///   - column0: A column identifier.
    ///   - column1: A second column identifier.
    ///   - column2: A third column identifier.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func grouped<T0, T1, T2>(by column0: ColumnID<T0>, _ column1: ColumnID<T1>, _ column2: ColumnID<T2>) -> some RowGroupingProtocol where T0 : Hashable, T1 : Hashable, T2 : Hashable { return unimplemented() }

}

/// Permit Never to be used as `some RowGroupingProtocol`
extension Never : RowGroupingProtocol {
    public var count: Int { unimplemented() }
    public func counts(order: Order?) -> DataFrame { unimplemented() }
    public func ungrouped() -> DataFrame { unimplemented() }
    public func mapGroups(_ transform: (DataFrame.Slice) throws -> DataFrame) rethrows -> Never { unimplemented() }
    public func summaryOfAllColumns() -> DataFrame { unimplemented() }
    public var description: String { unimplemented() }

    public func randomSplit(by proportion: Double, seed: Int?) -> (Never, Never) { unimplemented() }
    public func numericSummary(of columnNames: [String]) -> DataFrame { unimplemented() }
    public func summary(of columnNames: [String]) -> DataFrame { unimplemented() }
    public func aggregated<Element, Result>(on columnNames: [String], naming: (String) -> String, transform: (DiscontiguousColumnSlice<Element>) throws -> Result?) rethrows -> DataFrame { unimplemented() }

}

extension DataFrameProtocol {

    /// Generates a data frame by joining with another data frame type with a common column you select by name.
    ///
    /// - Parameters:
    ///   - other: A data frame type that represents the right side of the join.
    ///   - columnName: A column name that exists in both data frame types.
    ///   - kind: A join operation type.
    /// - Returns: A new data frame.
    public func join<R>(_ other: R, on columnName: String, kind: JoinKind = .inner) -> DataFrame where R : DataFrameProtocol { unimplemented() }

    /// Generates a data frame by joining with another data frame type with a common column
    /// that you select by identifier.
    ///
    /// - Parameters:
    ///   - other: A data frame type that represents the right side of the join.
    ///   - columnID: A column identifier that exists in both data frame types.
    ///   - kind: A join operation type.
    /// - Returns: A new data frame.
    public func join<R, T>(_ other: R, on columnID: ColumnID<T>, kind: JoinKind = .inner) -> DataFrame where R : DataFrameProtocol, T : Hashable { unimplemented() }

    /// Generates a data frame by joining with another data frame type along
    /// the columns that you select by name for both data frame types.
    ///
    /// - Parameters:
    ///   - other: A data frame type that represents the right side of the join.
    ///   - columnNames: The column names of the data frame and the other data frame type, `other`, respectively.
    ///   - kind: A join operation type.
    /// - Returns: A new data frame.
    public func join<R>(_ other: R, on columnNames: (left: String, right: String), kind: JoinKind = .inner) -> DataFrame where R : DataFrameProtocol { unimplemented() }

    /// Generates a data frame by joining with another data frame type along
    /// the columns that you select by identifier for both data frame types.
    ///
    /// - Parameters:
    ///   - other: A data frame type that represents the right side of the join.
    ///   - columnIDs: The column identifiers of the data frame and the other data frame type, `other`, respectively.
    ///   - kind: A join operation type.
    /// - Returns: A new data frame.
    public func join<R, T>(_ other: R, on columnIDs: (left: ColumnID<T>, right: ColumnID<T>), kind: JoinKind = .inner) -> DataFrame where R : DataFrameProtocol, T : Hashable { unimplemented() }
}

/// A collection that represents a selection, potentially with gaps, of elements from a typed column.
///
/// A column slice contains only certain elements from its parent column.
/// Create a slice by selecting certain elements.
/// For example, use ``filter(_:)`` to create a slice that only includes elements with even values.
///
/// ```swift
/// let slice = column.filter({ $0.isMultiple(of: 2) }) { unimplemented() }
/// ```
public struct DiscontiguousColumnSlice<WrappedElement> : OptionalColumnProtocol {

    /// The type of the column slice's elements.
    public typealias Element = WrappedElement?

    /// The type that represents a position in the column slice.
    public typealias Index = Int

    /// The name of the slice's parent column.
    public var name: String

    /// The underlying type of the column’s elements.
    public var wrappedElementType: Any.Type { unimplemented() }

    /// A prototype that creates type-erased columns with the same underlying type as the column slice.
    ///
    /// Use a type-erased column prototype to create new columns of the same type as the slice's parent column
    /// without explicitly knowing what type it is.
    public var prototype: AnyColumnPrototype { unimplemented() }

    /// Creates a slice with the contents of a column.
    ///
    /// - Parameter column: A column.
    public init(_ column: Column<WrappedElement>) { unimplemented() }

    /// Creates a slice with the contents of a column.
    ///
    /// - Parameter column: A column.
    /// - Parameter ranges: An array of integer ranges.
    public init(column: Column<WrappedElement>, ranges: [Range<Int>]) { unimplemented() }

    /// Creates a new column by applying a transformation to each element.
    ///
    /// - Parameter transform: A closure that transforms the column slice's elements to another type.
    public func map<T>(_ transform: (DiscontiguousColumnSlice<WrappedElement>.Element) throws -> T?) rethrows -> Column<T> { unimplemented() }

    /// Generates a slice that contains the elements that satisfy the predicate.
    ///
    /// - Parameter isIncluded: A predicate closure that returns a Boolean.
    /// The method uses the closure to determine whether it includes an element in the slice.
    public func filter(_ isIncluded: (DiscontiguousColumnSlice<WrappedElement>.Element) throws -> Bool) rethrows -> DiscontiguousColumnSlice<WrappedElement> { unimplemented() }

    /// Generates a type-erased copy of the column slice.
    public func eraseToAnyColumn() -> AnyColumnSlice { unimplemented() }
}

extension DiscontiguousColumnSlice where WrappedElement : Hashable {

    /// Generates a categorical summary of the column slice's elements that aren't missing.
    public func summary() -> CategoricalSummary<WrappedElement> { unimplemented() }
}

extension DiscontiguousColumnSlice {

    /// Modifies a column slice by adding a value to each element.
    ///
    /// - Parameters:
    ///   - lhs: A column slice.
    ///   - rhs: A value of the same type as the column's elements.
    public static func += (lhs: inout DiscontiguousColumnSlice<WrappedElement>, rhs: WrappedElement) where WrappedElement : AdditiveArithmetic { unimplemented() }

    /// Modifies a column slice by subtracting a value from each element.
    ///
    /// - Parameters:
    ///   - lhs: A column slice.
    ///   - rhs: A value of the same type as the column's elements.
    public static func -= (lhs: inout DiscontiguousColumnSlice<WrappedElement>, rhs: WrappedElement) where WrappedElement : AdditiveArithmetic { unimplemented() }

    /// Modifies a column slice by multiplying each element by a value.
    ///
    /// - Parameters:
    ///   - lhs: A column slice.
    ///   - rhs: A value of the same type as the column's elements.
    public static func *= (lhs: inout DiscontiguousColumnSlice<WrappedElement>, rhs: WrappedElement) where WrappedElement : Numeric { unimplemented() }

    /// Modifies an integer column slice by dividing each element by a value.
    ///
    /// - Parameters:
    ///   - lhs: A column slice.
    ///   - rhs: A value of the same type as the column's elements.
    public static func /= (lhs: inout DiscontiguousColumnSlice<WrappedElement>, rhs: WrappedElement) where WrappedElement : BinaryInteger { unimplemented() }

    /// Modifies a floating-point column slice by dividing each element by a value.
    ///
    /// - Parameters:
    ///   - lhs: A column slice.
    ///   - rhs: A value of the same type as the column's elements.
    public static func /= (lhs: inout DiscontiguousColumnSlice<WrappedElement>, rhs: WrappedElement) where WrappedElement : FloatingPoint { unimplemented() }
}

extension DiscontiguousColumnSlice : BidirectionalCollection, MutableCollection {

    /// The index of the initial element in the column slice.
    public var startIndex: Int { unimplemented() }

    /// The index of the final element in the column slice.
    public var endIndex: Int { unimplemented() }

    /// Returns the index immediately after an element index.
    /// - Parameter i: A valid index to an element in the column slice.
    public func index(after i: Int) -> Int { unimplemented() }

    /// Returns the index immediately before an element index.
    /// - Parameter i: A valid index to an element in the column slice.
    public func index(before i: Int) -> Int { unimplemented() }

    /// The number of elements in the column slice.
    public var count: Int { unimplemented() }

    /// Accesses an element at an index.
    ///
    /// - Parameter position: A valid index to an element in the column slice.
    public subscript(position: Int) -> DiscontiguousColumnSlice<WrappedElement>.Element { get { unimplemented() } set { unimplemented() } }

    /// Returns a Boolean that indicates whether the element at the index is missing.
    ///
    /// - Parameter index: An index.
    public func isNil(at index: Int) -> Bool { unimplemented() }

    /// Accesses a contiguous range of elements.
    ///
    /// - Parameter range: A range of valid indices in the column slice.
    public subscript(range: Range<Int>) -> DiscontiguousColumnSlice<WrappedElement> { unimplemented() }

    /// Accesses a contiguous range of elements with a range expression.
    ///
    /// - Parameter range: A range expression of valid indices in the column slice.
    @inlinable public subscript<R>(range: R) -> DiscontiguousColumnSlice<WrappedElement> where R : RangeExpression, R.Bound == Int { unimplemented() }

    /// Accesses a contiguous range of elements with an unbounded range.
    ///
    /// - Parameter range: An unbounded range of valid indices in the column slice.
    @inlinable public subscript(range: (UnboundedRange_) -> ()) -> DiscontiguousColumnSlice<WrappedElement> { unimplemented() }

    /// A type that represents the indices that are valid for subscripting the
    /// collection, in ascending order.
    public typealias Indices = DefaultIndices<DiscontiguousColumnSlice<WrappedElement>>

    /// A type that provides the collection's iteration interface and
    /// encapsulates its iteration state.
    ///
    /// By default, a collection conforms to the `Sequence` protocol by
    /// supplying `IndexingIterator` as its associated `Iterator`
    /// type.
    public typealias Iterator = IndexingIterator<DiscontiguousColumnSlice<WrappedElement>>

    /// A sequence that represents a contiguous subrange of the collection's
    /// elements.
    ///
    /// This associated type appears as a requirement in the `Sequence`
    /// protocol, but it is restated here with stricter constraints. In a
    /// collection, the subsequence should also conform to `Collection`.
    public typealias SubSequence = DiscontiguousColumnSlice<WrappedElement>
}

extension DiscontiguousColumnSlice : Equatable where WrappedElement : Equatable {

    /// Returns a Boolean that indicates whether the column slices are equal.
    /// - Parameters:
    ///   - lhs: A discontiguous column slice.
    ///   - rhs: Another discontiguous column slice.
    public static func == (lhs: DiscontiguousColumnSlice<WrappedElement>, rhs: DiscontiguousColumnSlice<WrappedElement>) -> Bool { unimplemented() }
}

extension DiscontiguousColumnSlice : Hashable where WrappedElement : Hashable {

    /// Hashes the essential components of the column slice by feeding them into a hasher.
    /// - Parameter hasher: A hasher the method uses to combine the components of the column slice.
    public func hash(into hasher: inout Hasher) { unimplemented() }

    /// Generates a discontiguous slice that contains unique elements.
    ///
    /// The method only adds the first of multiple elements with the same value
    /// --- the element with the smallest index ---
    /// to the slice.
    ///
    /// - Returns: A discontiguous column slice.
    public func distinct() -> DiscontiguousColumnSlice<WrappedElement> { unimplemented() }

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    public var hashValue: Int { unimplemented() }
}

extension DiscontiguousColumnSlice {

    /// Modifies a column slice by adding each value in a collection to
    /// the corresponding element in the column.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func += <C>(lhs: inout DiscontiguousColumnSlice<WrappedElement>, rhs: C) where WrappedElement : AdditiveArithmetic, WrappedElement == C.Element, C : Collection { unimplemented() }

    /// Modifies a column slice by adding each optional value in a collection to
    /// the corresponding element in the column.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func += <C>(lhs: inout DiscontiguousColumnSlice<WrappedElement>, rhs: C) where WrappedElement : AdditiveArithmetic, C : Collection, C.Element == WrappedElement? { unimplemented() }

    /// Modifies a column slice by subtracting each value in a collection from
    /// the corresponding element in the column.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func -= <C>(lhs: inout DiscontiguousColumnSlice<WrappedElement>, rhs: C) where WrappedElement : AdditiveArithmetic, WrappedElement == C.Element, C : Collection { unimplemented() }

    /// Modifies a column slice by subtracting each optional value in a collection from
    /// the corresponding element in the column.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func -= <C>(lhs: inout DiscontiguousColumnSlice<WrappedElement>, rhs: C) where WrappedElement : AdditiveArithmetic, C : Collection, C.Element == WrappedElement? { unimplemented() }

    /// Modifies a column slice by multiplying each element in the column by
    /// the corresponding value in a collection.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func *= <C>(lhs: inout DiscontiguousColumnSlice<WrappedElement>, rhs: C) where WrappedElement : Numeric, WrappedElement == C.Element, C : Collection { unimplemented() }

    /// Modifies a column slice by multiplying each element in the column by
    /// the corresponding optional value in a collection.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func *= <C>(lhs: inout DiscontiguousColumnSlice<WrappedElement>, rhs: C) where WrappedElement : Numeric, C : Collection, C.Element == WrappedElement? { unimplemented() }

    /// Modifies an integer column slice by dividing each element in the column by
    /// the corresponding value in a collection.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func /= <C>(lhs: inout DiscontiguousColumnSlice<WrappedElement>, rhs: C) where WrappedElement : BinaryInteger, WrappedElement == C.Element, C : Collection { unimplemented() }

    /// Modifies an integer column slice by dividing each element in the column by
    /// the corresponding optional value in a collection.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func /= <C>(lhs: inout DiscontiguousColumnSlice<WrappedElement>, rhs: C) where WrappedElement : BinaryInteger, C : Collection, C.Element == WrappedElement? { unimplemented() }

    /// Modifies a floating-point column slice by dividing each element in the column by
    /// the corresponding value in a collection.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func /= <C>(lhs: inout DiscontiguousColumnSlice<WrappedElement>, rhs: C) where WrappedElement : FloatingPoint, WrappedElement == C.Element, C : Collection { unimplemented() }

    /// Modifies a floating-point column slice by dividing each element in the column by
    /// the corresponding optional value in a collection.
    ///
    /// - Parameters:
    ///   - lhs: A column.
    ///   - rhs: A collection that contains elements of the same type as the column's elements.
    public static func /= <C>(lhs: inout DiscontiguousColumnSlice<WrappedElement>, rhs: C) where WrappedElement : FloatingPoint, C : Collection, C.Element == WrappedElement? { unimplemented() }
}

extension DiscontiguousColumnSlice where WrappedElement : Comparable {

    /// Returns the element with the lowest value, ignoring missing elements.
    public func min() -> DiscontiguousColumnSlice<WrappedElement>.Element { unimplemented() }

    /// Returns the element with the highest value, ignoring missing elements.
    public func max() -> DiscontiguousColumnSlice<WrappedElement>.Element { unimplemented() }

    /// Returns the index of the element with the lowest value, ignoring missing elements.
    public func argmin() -> Int? { unimplemented() }

    /// Returns the index of the element with the highest value, ignoring missing elements.
    public func argmax() -> Int? { unimplemented() }
}

extension DiscontiguousColumnSlice where WrappedElement : AdditiveArithmetic {

    /// Returns the sum of the column slice's elements, ignoring missing elements.
    public func sum() -> WrappedElement { unimplemented() }
}

extension DiscontiguousColumnSlice where WrappedElement : FloatingPoint {

    /// Returns the mean average of the floating-point slice's elements, ignoring missing elements.
    public func mean() -> DiscontiguousColumnSlice<WrappedElement>.Element { unimplemented() }

    /// Returns the standard deviation of the floating-point column slice's elements, ignoring missing elements.
    ///
    /// - Parameter deltaDegreesOfFreedom: A nonnegative integer.
    /// The method calculates the standard deviation's divisor by subtracting this parameter from the number of
    /// non-`nil` elements (`n - deltaDegreesOfFreedom` where `n` is the number of non-`nil` elements).
    ///
    /// - Returns: The standard deviation; otherwise, `nil` if there are fewer than
    /// `deltaDegreesOfFreedom + 1` non-`nil` items in the column.
    public func standardDeviation(deltaDegreesOfFreedom: Int = 1) -> DiscontiguousColumnSlice<WrappedElement>.Element { unimplemented() }
}

extension DiscontiguousColumnSlice where WrappedElement : BinaryInteger {

    /// Returns the mean average of the integer slice's elements, ignoring missing elements.
    public func mean() -> Double? { unimplemented() }

    /// Returns the standard deviation of the integer column slice's elements, ignoring missing elements.
    ///
    /// - Parameter deltaDegreesOfFreedom: A nonnegative integer.
    /// The method calculates the standard deviation's divisor by subtracting this parameter from the number of
    /// non-`nil` elements (`n - deltaDegreesOfFreedom` where `n` is the number of non-`nil` elements).
    ///
    /// - Returns: The standard deviation; otherwise, `nil` if there are fewer than
    /// `deltaDegreesOfFreedom + 1` non-`nil` items in the column.
    public func standardDeviation(deltaDegreesOfFreedom: Int = 1) -> Double? { unimplemented() }
}

extension DiscontiguousColumnSlice : CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {

    /// A text representation of the column slice.
    public var description: String { unimplemented() }

    /// A text representation of the column slice suitable for debugging.
    public var debugDescription: String { unimplemented() }

    /// A mirror that reflects the column slice.
    public var customMirror: Mirror { unimplemented() }
}

extension DiscontiguousColumnSlice where WrappedElement : FloatingPoint {

    /// Generates a numeric summary of the floating-point column slice's elements.
    public func numericSummary() -> NumericSummary<WrappedElement> { unimplemented() }
}

extension DiscontiguousColumnSlice where WrappedElement : BinaryInteger {

    /// Generates a numeric summary of the integer column slice's elements.
    public func numericSummary() -> NumericSummary<Double> { unimplemented() }
}

/// A view on a column that replaces missing elements with a default value.
public struct FilledColumn<Base> : ColumnProtocol where Base : OptionalColumnProtocol {

    /// The type of the column's elements that defines an associated type for the bidirectional collection protocol.
    ///
    /// See <doc://com.apple.documentation/documentation/Swift/BidirectionalCollection> for more information.
    public typealias Element = Base.WrappedElement

    /// The type of the column's elements that defines an associated type for the optional column protocol.
    ///
    /// See ``OptionalColumnProtocol`` for more information.
    public typealias WrappedElement = Base.WrappedElement

    /// The name of the column.
    public var name: String

    /// The index of the initial element in the column.
    @inlinable public var startIndex: Base.Index { unimplemented() }

    /// The index of the final element in the column.
    @inlinable public var endIndex: Base.Index { unimplemented() }

    /// Returns the position immediately after an index.
    /// - Parameter i: A valid index to a row in the grouping.
    @inlinable public func index(after i: Base.Index) -> Base.Index { unimplemented() }

    /// Returns the row index immediately before a row index.
    /// - Parameter i: A valid index to a row in the grouping.
    @inlinable public func index(before i: Base.Index) -> Base.Index { unimplemented() }

    /// Retrieves an element at a position in the column type.
    ///
    /// - Parameter position: A valid index in the column type.
    @inlinable public subscript(position: Base.Index) -> Base.WrappedElement { unimplemented() }

    /// A type that represents a position in the collection.
    ///
    /// Valid indices consist of the position of every element and a
    /// "past the end" position that's not valid for use as a subscript
    /// argument.
    public typealias Index = Base.Index

    /// A type that represents the indices that are valid for subscripting the
    /// collection, in ascending order.
    public typealias Indices = DefaultIndices<FilledColumn<Base>>

    /// A type that provides the collection's iteration interface and
    /// encapsulates its iteration state.
    ///
    /// By default, a collection conforms to the `Sequence` protocol by
    /// supplying `IndexingIterator` as its associated `Iterator`
    /// type.
    public typealias Iterator = IndexingIterator<FilledColumn<Base>>

    /// A sequence that represents a contiguous subrange of the collection's
    /// elements.
    ///
    /// This associated type appears as a requirement in the `Sequence`
    /// protocol, but it is restated here with stricter constraints. In a
    /// collection, the subsequence should also conform to `Collection`.
    public typealias SubSequence = Slice<FilledColumn<Base>>
}

extension FilledColumn where Base.WrappedElement : Hashable {

    /// Generates a categorical summary of the filled column's elements, including default values.
    public func summary() -> CategoricalSummary<Base.WrappedElement> { unimplemented() }
}

extension FilledColumn where Base.WrappedElement : Comparable {

    /// Returns the element with the lowest value.
    public func min() -> FilledColumn<Base>.Element? { unimplemented() }

    /// Returns the element with the highest value.
    public func max() -> FilledColumn<Base>.Element? { unimplemented() }

    /// Returns the index of the element with the lowest value.
    public func argmin() -> FilledColumn<Base>.Index? { unimplemented() }

    /// Returns the index of the element with the highest value.
    public func argmax() -> FilledColumn<Base>.Index? { unimplemented() }
}

extension FilledColumn where Base.WrappedElement : BinaryInteger {

    /// Returns the sum of the integer column's elements.
    public func sum() -> FilledColumn<Base>.Element { unimplemented() }

    /// Returns the mean average of the integer column's elements.
    public func mean() -> Double? { unimplemented() }

    /// Returns the standard deviation of the integer column's elements.
    ///
    /// - Parameter deltaDegreesOfFreedom: A nonnegative integer.
    /// The method calculates the standard deviation's divisor by subtracting this parameter from the number of
    /// non-`nil` elements (`n - deltaDegreesOfFreedom` where `n` is the number of non-`nil` elements).
    ///
    /// - Returns: The standard deviation; otherwise, `nil` if there are fewer than
    /// `deltaDegreesOfFreedom + 1` non-`nil` items in the column.
    public func standardDeviation(deltaDegreesOfFreedom: Int = 1) -> Double? { unimplemented() }
}

extension FilledColumn where Base.WrappedElement : FloatingPoint {

    /// Returns the sum of the floating-point column's elements.
    public func sum() -> FilledColumn<Base>.Element { unimplemented() }

    /// Returns the mean average of the floating-point column's elements.
    public func mean() -> FilledColumn<Base>.Element? { unimplemented() }

    /// Returns the standard deviation of the floating-point column's elements.
    ///
    /// - Parameter deltaDegreesOfFreedom: A nonnegative integer.
    /// The method calculates the standard deviation's divisor by subtracting this parameter from the number of
    /// non-`nil` elements (`n - deltaDegreesOfFreedom` where `n` is the number of non-`nil` elements).
    ///
    /// - Returns: The standard deviation; otherwise, `nil` if there are fewer than
    /// `deltaDegreesOfFreedom + 1` non-`nil` items in the column.
    public func standardDeviation(deltaDegreesOfFreedom: Int = 1) -> FilledColumn<Base>.Element? { unimplemented() }
}

extension FilledColumn : CustomStringConvertible {

    /// A mirror that reflects the filled column.
    public var description: String { unimplemented() }

    /// A text representation of the filled column suitable for debugging.
    public var debugDescription: String { unimplemented() }

    /// Generates a string description of the filled column.
    ///
    /// - Parameter options: The formatting options.
    public func description(options: FormattingOptions) -> String { unimplemented() }
}

extension FilledColumn where Base.WrappedElement : FloatingPoint {

    /// Generates a numeric summary of the floating-point column's elements.
    public func numericSummary() -> NumericSummary<Base.WrappedElement> { unimplemented() }
}

extension FilledColumn where Base.WrappedElement : BinaryInteger {

    /// Generates a numeric summary of the integer column's elements.
    public func numericSummary() -> NumericSummary<Double> { unimplemented() }
}

/// A set of parameters that indicate how to present the contents of data frame or column types to a printable string.
public struct FormattingOptions {

    /// The largest number of characters a description can generate per line.
    public var maximumLineWidth: Int

    /// The largest number of characters a description can generate per cell.
    public var maximumCellWidth: Int

    /// The largest number of rows a description can generate.
    public var maximumRowCount: Int

    /// A Boolean that indicates whether the description prints a column's type.
    public var includesColumnTypes: Bool

    /// Creates printing options for a description generator.
    /// - Parameters:
    ///   - maximumLineWidth: The largest number of characters a description can generate per line.
    ///   - maximumCellWidth: The largest number of characters a description can generate per cell.
    ///   - maximumRowCount: The largest number of rows a description can generate.
    ///   - includesColumnTypes: A Boolean that indicates whether the description prints a column's type.
    public init(maximumLineWidth: Int = 80, maximumCellWidth: Int = 15, maximumRowCount: Int = 10, includesColumnTypes: Bool = true) { unimplemented() }
}

/// A JSON reading error.
public enum JSONReadingError : Error {

    /// An error that occurs when the JSON structure is incompatible with a data frame.
    case unsupportedStructure

    /// An error that occurs when the JSON data contains a value of the wrong type for a type-constrained column.
    ///
    /// - Parameters:
    ///   - row: The index of the row that contains the incorrect value.
    ///   - column: The name of the column that contains the incorrect value.
    ///   - expectedType: The expected type.
    ///   - value: The JSON value.
    case wrongType(row: Int, column: String, expectedType: JSONType, value: Any)

    /// An error that occurs when the JSON data contains incompatible values in a column.
    ///
    /// - Parameters:
    ///   - column: The name of the column that contains the incompatible values.
    case incompatibleValues(column: String)

    /// An error that occurs when a JSON value fails to parse as the specified type.
    ///
    /// - Parameters:
    ///   - row: The index of the row that contains the incorrect value.
    ///   - column: The name of the column that contains the incorrect value.
    ///   - expectedType: The expected type.
    ///   - value: The JSON value.
    case failedToParse(row: Int, column: String, type: JSONType, contents: String)
}

extension JSONReadingError : CustomStringConvertible {

    /// A text representation of the error.
    public var description: String { unimplemented() }
}

/// A set of JSON file-reading options.
public struct JSONReadingOptions {

    /// An array of closures that parse a date from a string.
    public var dateParsers: [(String) -> Date?] { unimplemented() }

    /// Creates a set of options for reading a JSON file.
    public init() { unimplemented() }

    /// Adds a date parsing strategy.
    /// - Parameter strategy: A parsing strategy that has a string input and a date output.
    //@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    //public mutating func addDateParseStrategy<T>(_ strategy: T) where T : ParseStrategy, T.ParseInput == String, T.ParseOutput == Date { unimplemented() }
}

/// Represents the value types in a JSON file.
public enum JSONType {

    /// An integer type.
    case integer

    /// A Boolean type.
    case boolean

    /// A double-precision floating-point type.
    case double

    /// A date type.
    case date

    /// A string type.
    case string

    /// An array type.
    case array

    /// An object type.
    case object

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: JSONType, b: JSONType) -> Bool { unimplemented() }

    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// Implement this method to conform to the `Hashable` protocol. The
    /// components used for hashing must be the same as the components compared
    /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
    /// with each of these components.
    ///
    /// - Important: Never call `finalize()` on `hasher`. Doing so may become a
    ///   compile-time error in the future.
    ///
    /// - Parameter hasher: The hasher to use when combining the components
    ///   of this instance.
    public func hash(into hasher: inout Hasher) { unimplemented() }

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    public var hashValue: Int { unimplemented() }
}

extension JSONType : Equatable {
}

extension JSONType : Hashable {
}

/// An operation type that joins two data frame types.
public enum JoinKind {

    /// A join kind that only contains rows with matching values in both data frame types.
    case inner

    /// A join kind that contains all rows from the left data frame type,
    /// and only the rows with matching values from the right data frame type.
    case left

    /// A join kind that contains all rows from the right data frame type,
    /// and only the rows with matching values from the left data frame type.
    case right

    /// A join kind that contains every row from both data frame types.
    case full

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: JoinKind, b: JoinKind) -> Bool { unimplemented() }

    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// Implement this method to conform to the `Hashable` protocol. The
    /// components used for hashing must be the same as the components compared
    /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
    /// with each of these components.
    ///
    /// - Important: Never call `finalize()` on `hasher`. Doing so may become a
    ///   compile-time error in the future.
    ///
    /// - Parameter hasher: The hasher to use when combining the components
    ///   of this instance.
    public func hash(into hasher: inout Hasher) { unimplemented() }

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    public var hashValue: Int { unimplemented() }
}

extension JoinKind : Equatable {
}

extension JoinKind : Hashable {
}

/// A summary of a numerical column.
public struct NumericSummary<Element> : Hashable, CustomStringConvertible where Element : FloatingPoint {

    /// The number of elements in a column, ignoring missing elements.
    public var count: Int

    /// The average mean of a column's values, ignoring missing elements.
    public var mean: Element

    /// The standard deviation of a column's values, ignoring missing elements.
    public var standardDeviation: Element

    /// The element with the lowest value, ignoring missing elements.
    public var min: Element

    /// The element with the highest value, ignoring missing elements.
    public var max: Element

    /// Creates a summary of a numerical column.
    ///
    /// - Parameters:
    ///   - count: The number of elements in a column, ignoring missing elements.
    ///   - mean: The average mean of a column's values, ignoring missing elements.
    ///   - standardDeviation: The standard deviation of a column's values, ignoring missing elements.
    ///   - min: The element with the lowest value, ignoring missing elements.
    ///   - max: The element with the highest value, ignoring missing elements.
    public init(count: Int, mean: Element, standardDeviation: Element, min: Element, max: Element) { unimplemented() }

    /// A text representation of the numeric summary.
    public var description: String { unimplemented() }

    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// Implement this method to conform to the `Hashable` protocol. The
    /// components used for hashing must be the same as the components compared
    /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
    /// with each of these components.
    ///
    /// - Important: Never call `finalize()` on `hasher`. Doing so may become a
    ///   compile-time error in the future.
    ///
    /// - Parameter hasher: The hasher to use when combining the components
    ///   of this instance.
    public func hash(into hasher: inout Hasher) { unimplemented() }

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: NumericSummary<Element>, b: NumericSummary<Element>) -> Bool { unimplemented() }

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    public var hashValue: Int { unimplemented() }
}


extension OptionalColumnProtocol {

    /// Generates a filled column by replacing missing elements with a value.
    ///
    /// - Parameter value: A value the method uses to replace the column's missing elements.
    /// - Returns: A filled column.
    public func filled(with value: Self.WrappedElement) -> FilledColumn<Self> { unimplemented() }
}

extension OptionalColumnProtocol {

    /// Generates a string description of the optional column type.
    ///
    /// - Parameter options: The formatting options.
    public func description(options: FormattingOptions) -> String { unimplemented() }
}

extension OptionalColumnProtocol where Self.WrappedElement : AdditiveArithmetic {

    /// Generates a column by adding each element in an optional column type to the corresponding elements of another.
    /// - Parameters:
    ///   - lhs: An optional column type.
    ///   - rhs: Another optional column type.
    /// - Returns: A new column.
    public static func + (lhs: Self, rhs: Self) -> Column<Self.WrappedElement> { unimplemented() }

    /// Generates a column by subtracting each element in an optional column type from
    /// the corresponding elements of another.
    /// - Parameters:
    ///   - lhs: An optional column type.
    ///   - rhs: Another optional column type.
    /// - Returns: A new column.
    public static func - (lhs: Self, rhs: Self) -> Column<Self.WrappedElement> { unimplemented() }
}

extension OptionalColumnProtocol where Self.WrappedElement : Numeric {

    /// Generates a column by multiplying each element in an optional column type
    /// by the corresponding elements of another.
    /// - Parameters:
    ///   - lhs: An optional column type.
    ///   - rhs: Another optional column type.
    /// - Returns: A new column.
    public static func * (lhs: Self, rhs: Self) -> Column<Self.WrappedElement> { unimplemented() }
}

extension OptionalColumnProtocol where Self.WrappedElement : BinaryInteger {

    /// Generates an integer column by dividing each element in an optional column type
    /// by the corresponding elements of another.
    /// - Parameters:
    ///   - lhs: An optional column type.
    ///   - rhs: Another optional column type.
    /// - Returns: A new column.
    public static func / (lhs: Self, rhs: Self) -> Column<Self.WrappedElement> { unimplemented() }
}

extension OptionalColumnProtocol where Self.WrappedElement : FloatingPoint {

    /// Generates a floating-point column by dividing each element in an optional column type
    /// by the corresponding elements of another.
    /// - Parameters:
    ///   - lhs: An optional column type.
    ///   - rhs: Another optional column type.
    /// - Returns: A new column.
    public static func / (lhs: Self, rhs: Self) -> Column<Self.WrappedElement> { unimplemented() }
}

extension OptionalColumnProtocol {

    /// Generates a column by adding a value to each element in an optional column.
    /// - Parameters:
    ///   - lhs: An optional column type.
    ///   - rhs: A value of the same type as the optional column.
    /// - Returns: A new column.
    public static func + (lhs: Self, rhs: Self.WrappedElement) -> Column<Self.WrappedElement> where Self.WrappedElement : AdditiveArithmetic { unimplemented() }

    /// Generates a column by adding each element in an optional column to a value.
    /// - Parameters:
    ///   - lhs: A value of the same type as the optional column's type.
    ///   - rhs: An optional column type.
    /// - Returns: A new column.
    public static func + (lhs: Self.WrappedElement, rhs: Self) -> Column<Self.WrappedElement> where Self.WrappedElement : AdditiveArithmetic { unimplemented() }

    /// Generates a column by subtracting a value from each element in an optional column type.
    /// - Parameters:
    ///   - lhs: An optional column type.
    ///   - rhs: A value of the same type as the optional column's type.
    /// - Returns: A new column.
    public static func - (lhs: Self, rhs: Self.WrappedElement) -> Column<Self.WrappedElement> where Self.WrappedElement : AdditiveArithmetic { unimplemented() }

    /// Generates a column by subtracting each element in an optional column from a value.
    /// - Parameters:
    ///   - lhs: A value of the same type as the optional column's type.
    ///   - rhs: An optional column type.
    /// - Returns: A new column.
    public static func - (lhs: Self.WrappedElement, rhs: Self) -> Column<Self.WrappedElement> where Self.WrappedElement : AdditiveArithmetic { unimplemented() }
}

extension OptionalColumnProtocol where Self.WrappedElement : Numeric {

    /// Generates a column by multiplying each element in an optional column by a value.
    /// - Parameters:
    ///   - lhs: An optional column type.
    ///   - rhs: A value of the same type as the optional column's type.
    /// - Returns: A new column.
    public static func * (lhs: Self, rhs: Self.WrappedElement) -> Column<Self.WrappedElement> { unimplemented() }

    /// Generates a column by multiplying a value by each element in an optional column type.
    /// - Parameters:
    ///   - lhs: A value of the same type as the optional column's type.
    ///   - rhs: An optional column type.
    /// - Returns: A new column.
    public static func * (lhs: Self.WrappedElement, rhs: Self) -> Column<Self.WrappedElement> { unimplemented() }
}

extension OptionalColumnProtocol where Self.WrappedElement : BinaryInteger {

    /// Generates an integer column by dividing each element in an optional column by a value.
    /// - Parameters:
    ///   - lhs: An optional column type.
    ///   - rhs: A value of the same type as the optional column's type.
    /// - Returns: A new column.
    public static func / (lhs: Self, rhs: Self.WrappedElement) -> Column<Self.WrappedElement> { unimplemented() }

    /// Generates an integer column by dividing a value by each element in an optional column type.
    /// - Parameters:
    ///   - lhs: A value of the same type as the optional column's type.
    ///   - rhs: An optional column type.
    /// - Returns: A new column.
    public static func / (lhs: Self.WrappedElement, rhs: Self) -> Column<Self.WrappedElement> { unimplemented() }
}

extension OptionalColumnProtocol where Self.WrappedElement : FloatingPoint {

    /// Generates a floating-point column by dividing each element in an optional column by a value.
    /// - Parameters:
    ///   - lhs: An optional column type.
    ///   - rhs: A value of the same type as the optional column's type.
    /// - Returns: A new column.
    public static func / (lhs: Self, rhs: Self.WrappedElement) -> Column<Self.WrappedElement> { unimplemented() }

    /// Generates a floating-point column by dividing a value by each element in an optional column type.
    /// - Parameters:
    ///   - lhs: A value of the same type as the optional column.
    ///   - rhs: An optional column type.
    /// - Returns: A new column.
    public static func / (lhs: Self.WrappedElement, rhs: Self) -> Column<Self.WrappedElement> { unimplemented() }
}

/// A type that represents a sort ordering.
public enum Order {

    /// A sort ordering that starts with the lowest value and monotonically proceeds to higher values.
    case ascending

    /// A sort ordering that starts with the highest value and monotonically proceeds to lower values.
    case descending

    /// Returns a Boolean that indicates whether the comparable types match the order's state.
    ///
    /// - Parameters:
    ///   - lhs: A comparable type.
    ///   - rhs: Another comparable type.
    public func areOrdered<T>(_ lhs: T, _ rhs: T) -> Bool where T : Comparable { unimplemented() }

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: Order, b: Order) -> Bool { unimplemented() }

    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// Implement this method to conform to the `Hashable` protocol. The
    /// components used for hashing must be the same as the components compared
    /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
    /// with each of these components.
    ///
    /// - Important: Never call `finalize()` on `hasher`. Doing so may become a
    ///   compile-time error in the future.
    ///
    /// - Parameter hasher: The hasher to use when combining the components
    ///   of this instance.
    public func hash(into hasher: inout Hasher) { unimplemented() }

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    public var hashValue: Int { unimplemented() }
}

extension Order : Equatable {
}

extension Order : Hashable {
}

/// A collection of row selections that have the same value in a column.
public struct RowGrouping<GroupingKey> : RowGroupingProtocol where GroupingKey : Hashable {

    /// A text representation of the row grouping.
    public var description: String { unimplemented() }

    /// Creates a row grouping from a list of groups.
    ///
    /// The member data frames must all have the same columns (count, names, and types).
    ///
    /// - Parameters:
    ///   - groups: An array of tuples. Each tuple pairs a key with a data frame type.
    ///   - groupKeysColumnName: The name of the grouping key column the row grouping creates when it generates a data
    ///   frame, such as its ``ungrouped()`` or ``counts(order:)`` methods.
    public init<D>(groups: [(GroupingKey?, D)], groupKeysColumnName: String) where D : DataFrameProtocol { unimplemented() }

    /// Generates a data frame with two columns, one that has a row for each group key and another for the number of
    /// rows in the group.
    ///
    /// - Parameter order: A sorting order the method uses to sort the data frame by its count column.
    ///
    /// The name of the data frame's column that stores the number of rows in each group is *count*.
    public func counts(order: Order? = nil) -> DataFrame { unimplemented() }

    /// Generates a data frame by aggregating each group's contents for each column you list by name.
    ///
    /// - Parameters:
    ///   - columnNames: A comma-separated, or variadic, list of column names.
    ///   - naming: A closure that converts a column name to another name.
    ///   - transform: A closure that aggregates a group's elements in a specific column.
    ///
    /// The data frame contains two columns that:
    /// - Identify each group
    /// - Store the results of your aggregation transform closure
    public func aggregated<Element, Result>(on columnNames: [String], naming: (String) -> String, transform: (DiscontiguousColumnSlice<Element>) throws -> Result?) rethrows -> DataFrame { unimplemented() }

    /// Generates a data frame that contains all the rows from each group in the row grouping.
    ///
    /// The method discards any column with the same name as the row grouping itself.
    public func ungrouped() -> DataFrame { unimplemented() }

    /// Generates a new row grouping that applies a transformation closure to each group in the original.
    ///
    /// - Parameter transform: A closure that generates a data frame from a data frame slice that represents a group.
    public func mapGroups(_ transform: (DataFrame.Slice) throws -> DataFrame) rethrows -> RowGrouping<GroupingKey> { unimplemented() }
}

extension RowGrouping {

    /// Generates two row groupings by randomly splitting the original with a proportion and a seed number.
    /// - Parameters:
    ///   - proportion: A proportion in the range `[0.0, 1.0]`.
    ///   - seed: A seed number for a random-number generator.
    /// - Returns: A tuple of two row groupings.
    public func randomSplit(by proportion: Double, seed: Int? = nil) -> (RowGrouping<GroupingKey>, RowGrouping<GroupingKey>) { unimplemented() }
}

extension RowGrouping {

    /// Generates a data frame with a single row that summarizes the columns of the row grouping.
    public func summaryOfAllColumns() -> DataFrame { unimplemented() }

    /// Generates a data frame with a single row that summarizes the columns you select by name.
    ///
    /// - Parameter columnNames: An array of column names.
    public func summary(of columnNames: [String]) -> DataFrame { unimplemented() }

    /// Generates a data frame with a single row that numerically summarizes the columns you select by name in an array.
    /// - Parameter columnNames: An array of column names.
    public func numericSummary(of columnNames: [String]) -> DataFrame { unimplemented() }
}

/// Date based grouping
extension RowGrouping {

    /// Creates a row grouping from a column with date or time elements.
    /// - Parameters:
    ///   - frame: A data frame type.
    ///   - columnName: The name of the column that stores a row's date and time information.
    ///   - timeUnit: A calendar component that tells the row grouping how to create its groups.
    public init<D>(frame: D, columnName: String, timeUnit: Calendar.Component) where GroupingKey == Int, D : DataFrameProtocol { unimplemented() }
}

extension RowGrouping : RandomAccessCollection {

    /// The index of the initial group in the row grouping.
    public var startIndex: Int { unimplemented() }

    /// The index of the final group in the row grouping.
    public var endIndex: Int { unimplemented() }

    /// Returns the index immediately after an element index.
    /// - Parameter i: A valid index to an element in the column.
    public func index(after i: Int) -> Int { unimplemented() }

    /// Returns the index immediately before an element index.
    /// - Parameter i: A valid index to an element in the column.
    public func index(before i: Int) -> Int { unimplemented() }

    /// The number of groups in the row grouping.
    public var count: Int { unimplemented() }

    /// Retrieves a group at an index.
    /// - Parameter position: A valid index to a group in the row grouping.
    public subscript(position: Int) -> (key: GroupingKey?, group: DataFrame.Slice) { get { unimplemented() } set { unimplemented() } }

    /// A type representing the sequence's elements.
    public typealias Element = (key: GroupingKey?, group: DataFrame.Slice)

    /// A type that represents a position in the collection.
    ///
    /// Valid indices consist of the position of every element and a
    /// "past the end" position that's not valid for use as a subscript
    /// argument.
    public typealias Index = Int

    /// A type that represents the indices that are valid for subscripting the
    /// collection, in ascending order.
    public typealias Indices = Range<Int>

    /// A type that provides the collection's iteration interface and
    /// encapsulates its iteration state.
    ///
    /// By default, a collection conforms to the `Sequence` protocol by
    /// supplying `IndexingIterator` as its associated `Iterator`
    /// type.
    public typealias Iterator = IndexingIterator<RowGrouping<GroupingKey>>

    /// A sequence that represents a contiguous subrange of the collection's
    /// elements.
    ///
    /// This associated type appears as a requirement in the `Sequence`
    /// protocol, but it is restated here with stricter constraints. In a
    /// collection, the subsequence should also conform to `Collection`.
    public typealias SubSequence = Slice<RowGrouping<GroupingKey>>
}

extension RowGroupingProtocol {

    /// Generates a data frame with two columns, one that has a row for each group key and another for the number of
    /// rows in the group.
    ///
    /// The name of the data frame's column that stores the number of rows in each group is *count*.
    public func counts() -> DataFrame { unimplemented() }

    /// Generates a data frame that contains the sum of each group's rows along a column you select
    /// by name.
    /// - Parameters:
    ///   - columnName: The name of a column.
    ///   - type: The type of the column.
    ///   - order: A sorting order the method uses to sort the data frame by its sum column.
    public func sums<N>(_ columnName: String, _ type: N.Type, order: Order? = nil) -> DataFrame where N : AdditiveArithmetic, N : Comparable { unimplemented() }

    /// Generates a data frame that contains the sum of each group's rows along a column you select
    /// by column identifier.
    /// - Parameters:
    ///   - columnID: A column identifier.
    ///   - order: A sorting order the method uses to sort the data frame by its sum column.
    public func sums<N>(_ columnID: ColumnID<N>, order: Order? = nil) -> DataFrame where N : AdditiveArithmetic, N : Comparable { unimplemented() }

    /// Generates a data frame that contains the average mean of each group's rows along a column you select
    /// by name.
    /// - Parameters:
    ///   - columnName: The name of a column.
    ///   - type: The type of the column.
    ///   - order: A sorting order the method uses to sort the data frame by its mean column.
    public func means<N>(_ columnName: String, _ type: N.Type, order: Order? = nil) -> DataFrame where N : FloatingPoint { unimplemented() }

    /// Generates a data frame that contains the average mean of each group's rows along a column you select
    /// by column identifier.
    /// - Parameters:
    ///   - columnID: A column identifier.
    ///   - order: A sorting order the method uses to sort the data frame by its mean column.
    public func means<N>(_ columnID: ColumnID<N>, order: Order? = nil) -> DataFrame where N : FloatingPoint { unimplemented() }

    /// Generates a data frame that contains the minimums of each group's rows along a column you select
    /// by name.
    /// - Parameters:
    ///   - columnName: The name of a column.
    ///   - type: The type of the column.
    ///   - order: A sorting order the method uses to sort the data frame by its minimum column.
    public func minimums<N>(_ columnName: String, _ type: N.Type, order: Order? = nil) -> DataFrame where N : Comparable { unimplemented() }

    /// Generates a data frame that contains the minimums of each group's rows along a column you select
    /// by column identifier.
    /// - Parameters:
    ///   - columnID: A column identifier.
    ///   - order: A sorting order the method uses to sort the data frame by its minimum column.
    public func minimums<N>(_ columnID: ColumnID<N>, order: Order? = nil) -> DataFrame where N : Comparable { unimplemented() }

    /// Generates a data frame that contains the maximums of each group's rows along a column you select
    /// by name.
    /// - Parameters:
    ///   - columnName: The name of a column.
    ///   - type: The type of the column.
    ///   - order: A sorting order the method uses to sort the data frame by its maximum column.
    public func maximums<N>(_ columnName: String, _ type: N.Type, order: Order? = nil) -> DataFrame where N : Comparable { unimplemented() }

    /// Generates a data frame that contains the maximums of each group's rows along a column you select
    /// by column identifier.
    /// - Parameters:
    ///   - columnID: A column identifier.
    ///   - order: A sorting order the method uses to sort the data frame by its maximum column.
    public func maximums<N>(_ columnID: ColumnID<N>, order: Order? = nil) -> DataFrame where N : Comparable { unimplemented() }

    /// Generates a data frame by aggregating each group's contents for each column you select by name.
    ///
    /// - Parameters:
    ///   - columnNames: A comma-separated, or variadic, list of column names.
    ///   - naming: A closure that converts a column name to another name.
    ///   - transform: A closure that aggregates a group's elements in a specific column.
    ///
    /// The data frame contains two columns that:
    /// - Identify each group
    /// - Store the results of your aggregation transform closure
    public func aggregated<Element, Result>(on columnNames: String..., naming: (String) -> String, transform: (DiscontiguousColumnSlice<Element>) throws -> Result?) rethrows -> DataFrame { unimplemented() }

    /// Generates a data frame with a column for the group identifier and a column of values from the transform.
    ///
    ///
    /// - Parameters:
    ///   - columnID: A column identifier.
    ///   - aggregatedColumnName: The name of the aggregation column the method adds to the data frame.
    ///   - transform: A closure that transforms each group's elements in the column.
    public func aggregated<Element, Result>(on columnID: ColumnID<Element>, into aggregatedColumnName: String? = nil, transform: (DiscontiguousColumnSlice<Element>) throws -> Result) rethrows -> DataFrame { unimplemented() }

    /// Generates two row groupings by randomly splitting the original with a proportion.
    /// - Parameters proportion: A proportion in the range `[0.0, 1.0]`.
    /// - Returns: A tuple of two row groupings.
    public func randomSplit(by proportion: Double) -> (Self, Self) { unimplemented() }
}

extension RowGroupingProtocol {

    /// Generates a data frame with a single row that summarizes the columns you list by name.
    ///
    /// - Parameter columnNames: A comma-separated, or variadic, list of column names.
    public func summary(of columnNames: String...) -> DataFrame { unimplemented() }

    /// Generates a data frame with a single row that numerically summarizes the columns you list by name.
    /// - Parameter columnNames: A comma-separated, or variadic, list of column names.
    public func numericSummary(of columnNames: String...) -> DataFrame { unimplemented() }
}

/// An error when reading a Turi Create scalable data frame.
public enum SFrameReadingError : Error {

    /// An error that indicates the scalable data frame directory is missing an archive file.
    case missingArchive

    /// An error that indicates the scalable data frame directory's archive file is corrupt.
    ///
    /// The associated value contains a description of the error.
    case badArchive(String)

    /// An error that indicates the scalable data frame contains an archive version or layout the framework doesn't
    /// support.
    ///
    /// The associated value contains a description of the error.
    case unsupportedArchive(String)

    /// An error that indicates the scalable data frame contains an unknown or unsupported data type.
    ///
    /// The associated value contains the unknown data type identifier.
    case unsupportedType(Int)

    /// An error that indicates the scalable data frame contains an unsupported data layout.
    ///
    /// The associated value contains a description of the error.
    case unsupportedLayout(String)

    /// An error that indicates the scalable data frame contains bad data encoding.
    ///
    /// The associated value contains a description of the error.
    case badEncoding(String)

    /// An error that indicates the scalable data frame is missing one of the requested columns.
    ///
    /// The associated value contains a description of the error.
    case missingColumn(String)
}

extension SFrameReadingError : CustomStringConvertible {

    /// A text representation of the error.
    public var description: String { unimplemented() }
}

/// A collection type that represents multidimensional data in a data frame element.
public struct ShapedData<Element> {

    /// An integer array that stores the size of each dimension in the corresponding element.
    public let shape: [Int]

    /// An integer array that stores the number of memory locations
    /// that span the length of each dimension in the corresponding element.
    public let strides: [Int]

    /// A linear array that stores the elements of the multidimensional array.
    public let contents: [Element]

    /// Creates a multidimensional shaped array from a one-dimensional array.
    /// - Parameters:
    ///   - shape: An integer array that stores the size of each dimension in the corresponding element.
    ///   - strides: An integer array that stores the number of memory locations
    ///   that span the length of each dimension in the corresponding element.
    ///   - contents: A linear array that stores the elements of the multidimensional array.
    public init(shape: [Int], strides: [Int], contents: [Element]) { unimplemented() }

    /// Retrieves an element using an index for each dimension.
    /// - Parameter indices: A comma-separated, or variadic, list of indices, with one for each dimension.
    public subscript(indices: Int...) -> Element { unimplemented() }
}

extension ShapedData : Equatable where Element : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (a: ShapedData<Element>, b: ShapedData<Element>) -> Bool { unimplemented() }
}

extension ShapedData : Hashable where Element : Hashable {

    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// Implement this method to conform to the `Hashable` protocol. The
    /// components used for hashing must be the same as the components compared
    /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
    /// with each of these components.
    ///
    /// - Important: Never call `finalize()` on `hasher`. Doing so may become a
    ///   compile-time error in the future.
    ///
    /// - Parameter hasher: The hasher to use when combining the components
    ///   of this instance.
    public func hash(into hasher: inout Hasher) { unimplemented() }

    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    public var hashValue: Int { unimplemented() }
}


#if canImport(Combile)
import Combine


extension DataFrame {

    /// Decodes the elements of a column you select by name.
    ///
    /// - Parameters:
    ///   - type: The type of the decodable value.
    ///   - columnName: The name of a column.
    ///   - decoder: A decoder that accepts the column's type.
    /// - Throws: `ColumnDecodingError` when the decoder fails to decode a column element.
    public mutating func decode<T, Decoder>(_ type: T.Type, inColumn columnName: String, using decoder: Decoder) throws where T : Decodable, Decoder : TopLevelDecoder

    /// Decodes the elements of a column you select by column identifier.
    ///
    /// - Parameters:
    ///   - type: The type of the decodable value.
    ///   - id: A column identifier.
    ///   - decoder: A decoder that accepts the column's type.
    /// - Throws: `ColumnDecodingError` when the decoder fails to decode a column element.
    public mutating func decode<T, Decoder>(_ type: T.Type, inColumn id: ColumnID<Decoder.Input>, using decoder: Decoder) throws where T : Decodable, Decoder : TopLevelDecoder
}


extension Column {

    /// Generates a column by decoding each element's data.
    ///
    /// - Parameters:
    ///   - type: The decodable value's type.
    ///   - decoder: A decoder.
    ///
    /// - Returns: A new column of decoded values.
    ///
    /// - Throws: `ColumnDecodingError` when the decoder fails to decode an element.
    public func decoded<T, Decoder>(_ type: T.Type, using decoder: Decoder) throws -> Column<T> where WrappedElement == Decoder.Input, T : Decodable, Decoder : TopLevelDecoder { unimplemented() }
}

extension AnyColumn {
    /// Decodes data for each element of the column.
    ///
    /// - Parameters:
    ///   - type: The type of the value to decode.
    ///   - decoder: A decoder that accepts the column elements' type.
    /// - Returns: A new column of decoded values.
    /// - Throws: `ColumnDecodingError` if an element fails to decode.
    public func decoded<T, Decoder>(_ type: T.Type, using decoder: Decoder) throws -> AnyColumn where T : Decodable, Decoder : TopLevelDecoder { unimplemented() }

    /// Decodes the data in each element of the column.
    ///
    /// - Parameters:
    ///   - type: The type of the value to decode.
    ///   - decoder: A decoder that accepts the column elements' type.
    /// - Throws: `ColumnDecodingError` if an element fails to decode.
    public mutating func decode<T, Decoder>(_ type: T.Type, using decoder: Decoder) throws where T : Decodable, Decoder : TopLevelDecoder { unimplemented() }
}

extension AnyColumn {

    /// Generates a column by encoding each element's value.
    ///
    /// - Parameters:
    ///   - type: The column underlying type.
    ///   - encoder: An encoder.
    ///
    /// - Returns: A new column of encoded values.
    ///
    /// - Throws: `ColumnEncodingError` when the encoder fails to encode an element.
    public func encoded<T, Encoder>(_ type: T.Type, using encoder: Encoder) throws -> AnyColumn where T : Encodable, Encoder : TopLevelEncoder { unimplemented() }

    /// Encodes each element of the column.
    ///
    /// - Parameters:
    ///   - type: The type of elements in the column.
    ///   - encoder: An encoder.
    /// - Throws: `ColumnEncodingError` if an element fails to encode.
    public mutating func encode<T, Encoder>(_ type: T.Type, using encoder: Encoder) throws where T : Encodable, Encoder : TopLevelEncoder { unimplemented() }
}

extension Column where WrappedElement : Encodable {

    /// Generates a column by encoding each element's value.
    ///
    /// - Parameters:
    ///   - encoder: An encoder.
    ///
    /// - Returns: A new column of encoded values.
    ///
    /// - Throws: `ColumnEncodingError` when the encoder fails to encode an element.
    public func encoded<Encoder>(using encoder: Encoder) throws -> Column<Encoder.Output> where Encoder : TopLevelEncoder { unimplemented() }
}


extension DataFrame {

    /// Encodes the elements of a column you select by name.
    ///
    /// - Parameters:
    ///   - columnName: The name of a column.
    ///   - type: The type of the column.
    ///   - encoder: A encoder that accepts the column's type.
    /// - Throws: `ColumnEncodingError` when the encoder fails to encode a column element.
    public mutating func encodeColumn<T, Encoder>(_ columnName: String, _ type: T.Type, using encoder: Encoder) throws where T : Encodable, Encoder : TopLevelEncoder

    /// Encodes the elements of a column you select by column identifier.
    ///
    /// - Parameters:
    ///   - id: The name of a column.
    ///   - encoder: A encoder that accepts the column's type.
    /// - Throws: `ColumnEncodingError` when the encoder fails to encode a column element.
    public mutating func encodeColumn<T, Encoder>(_ id: ColumnID<T>, using encoder: Encoder) throws where T : Encodable, Encoder : TopLevelEncoder
}

#endif



/// Generates a column by multiplying each element in an optional column type
/// by the corresponding elements of a column type.
/// - Parameters:
///   - lhs: An optional column type.
///   - rhs: A column type.
/// - Returns: A new column with the same type as the right column.
public func * <L, R>(lhs: L, rhs: R) -> Column<R.Element> where L : OptionalColumnProtocol, R : ColumnProtocol, L.WrappedElement : Numeric, L.WrappedElement == R.Element { unimplemented() }

/// Generates a column by multiplying each element in a column type
/// by the corresponding elements of an optional column type.
/// - Parameters:
///   - lhs: A column type.
///   - rhs: An optional column type.
/// - Returns: A new column with the same type as the left column.
public func * <L, R>(lhs: L, rhs: R) -> Column<L.Element> where L : ColumnProtocol, R : OptionalColumnProtocol, L.Element : Numeric, L.Element == R.WrappedElement { unimplemented() }

/// Generates a column by adding each element in an optional column type to the corresponding elements of a column type.
/// - Parameters:
///   - lhs: An optional column type.
///   - rhs: A column type.
/// - Returns: A new column with the same type as the right column.
public func + <L, R>(lhs: L, rhs: R) -> Column<R.Element> where L : OptionalColumnProtocol, R : ColumnProtocol, L.WrappedElement : AdditiveArithmetic, L.WrappedElement == R.Element { unimplemented() }

/// Generates a column by adding each element in a column type to the corresponding elements of an optional column type.
/// - Parameters:
///   - lhs: A column type.
///   - rhs: An optional column type.
/// - Returns: A new column with the same type as the left column.
public func + <L, R>(lhs: L, rhs: R) -> Column<L.Element> where L : ColumnProtocol, R : OptionalColumnProtocol, L.Element : AdditiveArithmetic, L.Element == R.WrappedElement { unimplemented() }

/// Generates a column by subtracting each element in a column type
/// from the corresponding elements of an optional column.
/// - Parameters:
///   - lhs: An optional column type.
///   - rhs: A column type.
/// - Returns: A new column with the same type as the right column.
public func - <L, R>(lhs: L, rhs: R) -> Column<R.Element> where L : OptionalColumnProtocol, R : ColumnProtocol, L.WrappedElement : AdditiveArithmetic, L.WrappedElement == R.Element { unimplemented() }

/// Generates a column by subtracting each element in an optional column type
/// from the corresponding elements of a column type.
/// - Parameters:
///   - lhs: A column type.
///   - rhs: An optional column type.
/// - Returns: A new column with the same type as the left column.
public func - <L, R>(lhs: L, rhs: R) -> Column<L.Element> where L : ColumnProtocol, R : OptionalColumnProtocol, L.Element : AdditiveArithmetic, L.Element == R.WrappedElement { unimplemented() }

/// Generates an integer column by dividing each element in an optional column type
/// by the corresponding elements of a column type.
/// - Parameters:
///   - lhs: An optional column type.
///   - rhs: A column type.
/// - Returns: A new column with the same type as the right column.
public func / <L, R>(lhs: L, rhs: R) -> Column<R.Element> where L : OptionalColumnProtocol, R : ColumnProtocol, L.WrappedElement : BinaryInteger, L.WrappedElement == R.Element { unimplemented() }

/// Generates an integer column by dividing each element in a column type
/// by the corresponding elements of an optional column type.
/// - Parameters:
///   - lhs: A column type.
///   - rhs: An optional column type.
/// - Returns: A new column with the same type as the left column.
public func / <L, R>(lhs: L, rhs: R) -> Column<L.Element> where L : ColumnProtocol, R : OptionalColumnProtocol, L.Element : BinaryInteger, L.Element == R.WrappedElement { unimplemented() }

/// Generates a floating-point column by dividing each element in an optional column type
/// by the corresponding elements of a column type.
/// - Parameters:
///   - lhs: An optional column type.
///   - rhs: A column type.
/// - Returns: A new column with the same type as the right column.
public func / <L, R>(lhs: L, rhs: R) -> Column<R.Element> where L : OptionalColumnProtocol, R : ColumnProtocol, L.WrappedElement : FloatingPoint, L.WrappedElement == R.Element { unimplemented() }

/// Generates a floating-point column by dividing each element in a column type
/// by the corresponding elements of an optional column type.
/// - Parameters:
///   - lhs: A column type.
///   - rhs: An optional column type.
/// - Returns: A new column with the same type as the left column.
public func / <L, R>(lhs: L, rhs: R) -> Column<L.Element> where L : ColumnProtocol, R : OptionalColumnProtocol, L.Element : FloatingPoint, L.Element == R.WrappedElement { unimplemented() }

#endif

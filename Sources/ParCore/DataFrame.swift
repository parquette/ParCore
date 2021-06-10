
#if canImport(TabularData)
import TabularData

/// Two-dimensional, size-mutable, potentially heterogeneous tabular data.
///
/// This is a shim for `TabularData.DataFrameProtocol` for systems where TabularData is unavailable
public protocol ParFrameProtocol : TabularData.DataFrameProtocol {

}

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
extension TabularData.DataFrame : ParFrameProtocol {
}
#else

public protocol ParFrameProtocol {

}

#endif



// Shim for missing process.getBuiltinModule in Node < 20.16.0 / < 22.3.0
// This prevents a TypeError in the 'bson' library which expects this function.
if (typeof process !== 'undefined' && !process.getBuiltinModule) {
  process.getBuiltinModule = (id) => {
    return undefined;
  };
}

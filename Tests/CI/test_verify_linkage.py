import unittest
from verify_linkage import verify_linkage

DYLIB = "  @rpath/ValueTraceKit.framework/ValueTraceKit (compatibility version 1.0.0)"
REEXPORT = "Load command 3\n    cmd LC_REEXPORT_DYLIB\n  name @rpath/ValueTraceKit.framework/ValueTraceKit (offset 24)"
SYMBOL = "000100000000e001 S _OBJC_CLASS_$_VTValueEvidence"

class LinkageChecks(unittest.TestCase):
    def test_debug_requires_reexport_and_bundle_binary(self):
        verify_linkage("Debug", DYLIB, REEXPORT, "", True)
        with self.assertRaises(ValueError):
            verify_linkage("Debug", DYLIB, REEXPORT.replace("REEXPORT", "LOAD"), "", True)
        with self.assertRaises(ValueError):
            verify_linkage("Debug", DYLIB, REEXPORT, "", False)

    def test_release_requires_definition_without_framework_dependency(self):
        verify_linkage("Release", "", "", SYMBOL, False)
        with self.assertRaises(ValueError):
            verify_linkage("Release", DYLIB, "", SYMBOL, False)
        with self.assertRaises(ValueError):
            verify_linkage("Release", "", "", " U _OBJC_CLASS_$_VTValueEvidence", False)

if __name__ == "__main__":
    unittest.main()

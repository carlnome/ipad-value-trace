# Public synthetic Block smoke test

This branch contains an independent synthetic UIKit fixture, not any internal trace implementation, source, capture payload or diagnostic data. It exercises a real Objective-C Block callback on the iPad Simulator, an opt-in probe generated at a fixed marker, and a minimal public ValueTraceKit evidence record. It does not test an AST instrumenter, BTrace, or any proprietary adapter.

Generate the fixture before running XcodeGen: `python3 Scripts/prepare_synthetic_callback.py`. On Debug, run with capture off, toggle on for two calls, then off for one call. The expected callback count increases 1–4; evidence counts are 0, 1, 2, 2. Release tests that the controls are absent even when the generated source exists. Individual XCTest screenshots are retained in the xcresult bundle.

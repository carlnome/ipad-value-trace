# iPad Value Trace

可复用的 iPad 诊断组件。首个里程碑是 `ValueTraceKit.framework`：以只读记录表示一个界面值的字段标识、显示内容、数据来源和计算规则。UIKit 示例宿主和 UI 测试只用于验证集成，不是项目主体。

## 初期验证

在 Xcode 26（带 iOS 26 Simulator SDK，无需启动模拟器）、XcodeGen 和 Python 3 环境执行：

```sh
brew install xcodegen
bash Scripts/ci.sh Debug
bash Scripts/ci.sh Release
```

也可以执行 `xcodegen generate`，用 Xcode 打开 `iPadValueTrace.xcodeproj`，运行 `ValueTraceExample`。点击两个显示为 `75%` 的值，分别看到 `demo.snapshot.capacity` / `round(used / total * 100)` 和 `demo.snapshot.score` / `round(score * 100)`。

GitHub Actions 对 Debug 和 Release 分别编译并检查链接。不启动模拟器、不发布 Release，也不上传构建产物。

- Debug：使用 `otool` 确认 App 重导出动态 Framework，并且包中含其二进制。
- Release：App 无该 Framework 的动态依赖，而 `nm` 能在 App 二进制中找到证据记录类的定义。不是仅靠编译设置判断合并成功。

示例仍保留可在 Xcode 手动运行的 UIKit 冒烟测试，不在本阶段 CI 运行。

## 集成方式

目标 App 直接链接并嵌入同工程的 `ValueTraceKit.framework`，开启 `MERGED_BINARY_TYPE=automatic`。Xcode 在 Debug 使用动态库重导出，在 Release 合并代码；两种配置使用同一个 Framework target 和源码。示例关闭 `ENABLE_DEBUG_DYLIB`，便于用一致路径检查 App 二进制。[Apple Mergeable Libraries 文档](https://developer.apple.com/documentation/xcode/configuring-your-project-to-use-mergeable-libraries)

当前只展示由绑定方提供的证据，不会根据相同的显示文字推断来源，也不读任意运行时变量。示例数据全为合成信息。尚未接入业务 App、线上代码库、LLM、真机签名或分发。

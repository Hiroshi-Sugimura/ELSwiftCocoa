- podspecをlintする

```
pod spec lint ELSwift.podspec
```

- 問題なければpassed validation
- pod trunk push でアップする

```
pod trunk push ELSwift.podspec
```

- 確認

```
pod trunk info ELSwift
```

- 新しいPCだとRegisterが求められる？

```
pod trunk register hiroshi.sugimura@gmail.com
# Emailチェック
```

## Trouble shoot

### unable to find utility "simctl",

```
ERROR | [iOS] unknown: Encountered an unknown error (/usr/bin/xcrun simctl list -j devices

xcrun: error: unable to find utility "simctl", not a developer tool or in PATH
) during validation.
```

- Xcode > Preferences > LocationsのCommand Line Toolsを選択する

- https://medium.com/codespace69/react-native-xcrun-error-unable-to-find-utility-simctl-not-a-developer-tool-or-in-path-bd908d3551be
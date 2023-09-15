# Contributing guide



## Contribution Steps
1. Make sure you are up to date with `main`
1. Run all tests: `flutter test`
1. Set up an alias to run commands locally (see below for instructions)
1. Hack away! Test your changes locally, and add unit tests to cover everything
1. Bump the version in the pubspec.yaml
1. Commit your changes
1. Make your PR!!! `gh pr create --fill`

## Run commands locally during development
```
dart <-path to this repo->/bin/changelog_bubbler.dart --help
```
example: 
```
dart /Users/micaiah.skolnick/Repos/changelog_bubbler/bin/changelog_bubbler.dart --help
```

Pro-tip: 

> You can create an alias to make it easier to develop locally. 
---

### Mac: 

1. Add an alias to your bash profile (default is .zshrc)

    ```
    alias local_bubbler='dart /Users/micaiah.skolnick/Repos/changelog_bubbler/bin/changelog_bubbler.dart'
    ```
1. Open a new terminal window
---

### Windows:

Add a function to your powershell profile. 
1. Create a file named `profile.ps1` at your powershell directory. eg: `C:\Users\micaiah.skolnick\Documents\WindowsPowerShell\profile.ps1`
1. Add the following function to your profile. **Replace the path with the path to the repository on your machine
    ```
    Function local_bubbler {
    dart run C:\Users\micaiah.skolnick\Repos\changelog_bubbler/bin/changelog_bubbler.dart $args 
    }
    ```
1. Open a new Powershell window

---

> Now you can run commands from anywhere like so: 
```
local_bubbler --help
```

### To test
General testing:
```
flutter test
```

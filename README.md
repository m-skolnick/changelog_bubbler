<h1 align="center">UNDER DEVELOPMENT - NOT READY FOR USE</h1>
<h1 align="center">Changelog Bubbler</h1>
<br/>

<p align="center">
<a href="https://github.com/m-skolnick/changelog_bubbler/actions/workflows/build.yaml"><img src="https://github.com/m-skolnick/changelog_bubbler/actions/workflows/build.yaml/badge.svg" alt="build status"></a>
<a href="https://codecov.io/gh/m-skolnick/changelog_bubbler"><img src="https://codecov.io/gh/m-skolnick/changelog_bubbler/branch/main/graph/badge.svg" alt="codecov"></a>
<a href="https://pub.dev/packages/changelog_bubbler"><img src="https://img.shields.io/pub/v/changelog_bubbler.svg" alt="Latest version on pub.dev"></a>
</p>

---
<br/>

<p align="center">Compiles changelogs from this package and every sub-package between specified git refs</p>

## Overview

The goal of this package is to automate the process of creating a changelog diff for flutter and dart applications. This package not only gathers the changelog diff from the current package. It also analyzes every sub-package and bubbles up their changelogs as well.

### How it Works

This package generates a single CHANGELOG_BUBBLES.md file which contains the changelog diff from this application and every depended on dart application.

This builder works as follows:
1. Read passed in args (ie.. ref to compare with current)
1. Copy source Repo into temp folder and check out at specified ref
1. Gather info of repo in states current and previous
    1. Run pub get
    1. Read pubspec lock
    1. Build dep list based on pubspec lock and pub_cache
    1. Store path to pub_cache in dependency class for later reference
1. Build release notes
    1. Private Hosted - Direct
    1. Private Hosted - Transitive
    1. pub.dev - Direct
    1. pub.dev - Transitive
1. Release note section building
    1. Only changed deps
    1. Print:
        1. name 1.0.0 -> 2.0.0
        1. Changelog new lines

1. Create a file with the information gathered above

## Usage
1. Add `changelog_bubbler` to `dev_dependencies` in `pubspec.yaml`

    ```yaml
    name: example_cli
    dev_dependencies:
      changelog_bubbler: ^1.0.0
    ```

1. Run a build

    ```console
    > dart pub run changelog_bubbler
    ```

1. `CHANGELOG_BUBBLED.g.md` will be generated with content:
># Bubbled Changelog
>
>Example app
>
>## Hosted - Direct
>
>my_app_core 1.0.0 -> 1.1.0
>
>\# 1.1.0
>- chore: something changed
>
>## pub.dev - Transitive
>
>analyzer 1.0.0 -> 2.0.0
>
>\# 2.0.0
>- chore: something changed
>
>\# 1.3.0
>- chore: something changed
>
>\# 1.1.0
>- chore: something changed
>

See a full example output here: [Example App Output][example_app_output]

**Note**
If you are using this in Github Actions, you will need to set the fetch-depth of the checkout command to "0" so that tags are fetched

```
    steps:
      - uses: actions/checkout@v3
        with:
          # Fetch depth 0 so that tags are fetched
          fetch-depth: 0
```

## Advanced

### Previous Ref
By default the changelog will be generated based on a diff between the current git state and the previous tag.

To specify your own ref, pass a flag named `previous-ref` with your desired git ref.

example:
```
dart pub run changelog_bubbler --previous-ref 8762db
```
example:
```
dart pub run changelog_bubbler --previous-ref v2.0.0
```

### Output File
To change the path of the generated file, pass a flag named `output`.

example:
```
dart pub run changelog_bubbler --output MY_COOL_CHANGELOG_NAME.md
```


## Maintainers

- [Micaiah Skolnick](https://github.com/m-skolnick)

[example_app_output]: https://github.com/m-skolnick/changelog_bubbler/blob/main/example/my_output_file.md
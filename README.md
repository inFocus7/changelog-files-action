# Changelog Files Action
Generates a changelog based on YAML files in a directory.

When a release tagged `TAG` is created, this action will generate a changelog based on the `TAG.(yaml|yml)` file in the `changelogs` directory.

## Action Definition

| Input               | Description                                                                     | Default Value |
|---------------------|---------------------------------------------------------------------------------|---------------|
| changelog-directory | The directory where changelog files are stored. Do not include a trailing slash | `changelogs`  |
| release-tag-name    | The name of the release tag.                                                    | None.         |

This action outputs the generated changelog to an artifact named `changelog_output.md`.

The changelog files to generate from should follow the following format:
```yaml
fix: <[]str>
enhancement: <[]str>
security: <[]str>
breaking: <[]str>
deprecated: <[]str>
docs: <[]str>
ci: <[]str>
```

## Example Usages

### Use Case: Default usage
```yaml
on:
  release:
    types: [created]

jobs:
  update-release-notes:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Generate Changelog
        id: changelog
        uses: infocus7/changelog-files-action@latest # You can also use a specific version or hash.
        with:
          changelog-directory: 'changelogs-fun'
          release-tag-name: ${{ github.ref_name }}
      - name: Download Changelog # This is needed because the action outputs the changelog to an artifact (file).
        uses: actions/download-artifact@v2
        with:
          name: changelog
      - name: Update Release Notes
        shell: bash
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          REPO_NAME: ${{ github.repository }}
          RELEASE_ID: ${{ github.event.release.id }}
        run: |
          changelog_content=$(jq -Rs . < changelog_output.md) # Convert the changelog to a JSON string so we can send it.
          curl -L -X PATCH \
            -H "Accept: application/vnd.github+json" \
            -H "Authorization: Bearer $GITHUB_TOKEN" \
            "https://api.github.com/repos/$REPO_NAME/releases/$RELEASE_ID" \
            -d "{\"body\": $changelog_content}"
```

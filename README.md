# Changelog Files Action
Generates a changelog based on YAML files in a directory.

When a release tagged `TAG` is created, this action will generate a changelog based on the `TAG.(yaml|yml)` file in the `changelogs` directory.

## Action Definition

| Input               | Description                                                                     | Default Value |
|---------------------|---------------------------------------------------------------------------------|---------------|
| changelog-directory | The directory where changelog files are stored. Do not include a trailing slash | `changelogs`  |
| release-tag-name    | The name of the release tag.                                                    | None.         |

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
        uses: infocus7/changelog-files-action@v1
        with:
          changelog-directory: 'path/to/changelogs'
          release-tag-name: ${{ github.ref_name }}
      - name: Update Release Notes
        uses: actions/github-script@v3
        with:
          github-token: ${{secrets.GITHUB_TOKEN}}
          script: |
            const releaseId = ${{ github.event.release.id }};
            const changelog = ${{ steps.changelog.outputs.changelog }};
            github.rest.repos.updateRelease({
              owner: context.repo.owner,
              repo: context.repo.repo,
              release_id: releaseId,
              body: changelog
            });
```

#!/bin/bash

# Check if the correct number of arguments is passed
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <changelog-directory> <release-tag-name>"
    exit 1
fi

CHANGELOG_DIR=$1
RELEASE_TAG=$2

# Check for both .yml and .yaml file extensions
YAML_FILEPATH="$CHANGELOG_DIR/$RELEASE_TAG.yml"
if [ ! -f "$YAML_FILEPATH" ]; then
    YAML_FILEPATH="$CHANGELOG_DIR/$RELEASE_TAG.yaml"
    if [ ! -f "$YAML_FILEPATH" ]; then
        echo "YAML file not found for tag $RELEASE_TAG in directory $CHANGELOG_DIR"
        exit 1
    fi
fi

# Function to parse and format a section of the YAML file
parse_section() {
    local section=$1
    local entries=$(yq e ".${section}[]" -o=json "$YAML_FILEPATH" | sed 's/^/ - /')

    local section_title=""
    case $section in
        "fix")
            section_title="Bug Fixes"
            ;;
        "enhancement")
            section_title="Enhancements"
            ;;
        "security")
            section_title="Security Updates"
            ;;
        "breaking")
            section_title="Breaking Changes"
            ;;
        "deprecated")
            section_title="Deprecations"
            ;;
        "docs")
            section_title="Documentation Changes"
            ;;
        "ci")
            section_title="CI/CD Changes"
            ;;
    esac

    if [ ! -z "$entries" ] && [ ! -z "$section_title" ]; then
        echo "## ${section_title}"
        echo "$entries"
        echo ""
    fi
}

# Generate Markdown content

# Get the version tag from the filename
VERSION_TAG=${YAML_FILEPATH##*/}
if [[ $VERSION_TAG == *.yml ]]; then
    VERSION_TAG=${VERSION_TAG%.yml}
elif [[ $VERSION_TAG == *.yaml ]]; then
    VERSION_TAG=${VERSION_TAG%.yaml}
fi


echo "# $VERSION_TAG Changelog\n"
# Parse each section
parse_section "fix"
parse_section "enhancement"
parse_section "security"
parse_section "breaking"
parse_section "deprecated"
parse_section "docs"
parse_section "ci"

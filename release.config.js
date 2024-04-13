module.exports = {
    branches: [
        {name: 'main'},
    ],
    plugins: [
        "@semantic-release/commit-analyzer",
        "@semantic-release/release-notes-generator",
        [
            "@semantic-release/changelog",
            {
                "changelogFile": "CHANGELOG.md"
            }
        ],
        [
            "@semantic-release/git",
            {
                "assets": [
                    "CHANGELOG.md"
                ],
                "message": "chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}"
            }
        ],
        "semantic-release-docker-buildx",
        [
            "@semantic-release/github",
            {
                "addReleases": "bottom"
            }
        ]
    ],
    publish: [
        {
            "path": "semantic-release-docker-buildx",
            "buildArgs": {
                "COMMIT_TAG": "$GIT_SHA"
            },
            "imageNames": [
                "betterdev/k8s-ci-cd"
            ],
            "platforms": [
                "linux/amd64",
                "linux/arm64",
                "linux/arm/v7"
            ]
        },
        "@semantic-release/github"
    ]
};

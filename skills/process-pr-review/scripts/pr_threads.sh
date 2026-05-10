#!/usr/bin/env bash
# Helper for the process-pr-review skill.
# Wraps the GraphQL + REST plumbing for fetching threads, posting replies,
# resolving threads, and re-requesting review on a GitHub PR.

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  pr_threads.sh detect-pr
      Output the PR number for the current branch (or fail if none).

  pr_threads.sh fetch <PR>
      Output a JSON array of unresolved review threads on PR <PR>.
      Each entry: {thread_id, comment_id, author, path, line, body, is_outdated}.

  pr_threads.sh reply <PR> <COMMENT_ID> <BODY_FILE>
      Post a reply on the thread containing <COMMENT_ID>. Body read from file.

  pr_threads.sh resolve <THREAD_ID>
      Mark a thread (GraphQL ID) as resolved.

  pr_threads.sh request-review <PR> <REVIEWER>
      Re-request review on PR <PR> from <REVIEWER>.
EOF
  exit 1
}

[[ $# -lt 1 ]] && usage

CMD=$1
shift

NWO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
OWNER=${NWO%/*}
REPO=${NWO#*/}

case "$CMD" in
  detect-pr)
    gh pr view --json number --jq .number
    ;;

  fetch)
    PR=${1:?PR number required}
    gh api graphql -f query="
      query {
        repository(owner: \"$OWNER\", name: \"$REPO\") {
          pullRequest(number: $PR) {
            reviewThreads(first: 100) {
              nodes {
                id
                isResolved
                isOutdated
                comments(first: 1) {
                  nodes {
                    databaseId
                    author { login }
                    path
                    line
                    body
                  }
                }
              }
            }
          }
        }
      }
    " --jq '.data.repository.pullRequest.reviewThreads.nodes
      | map(select(.isResolved == false))
      | map({
          thread_id: .id,
          comment_id: .comments.nodes[0].databaseId,
          author: .comments.nodes[0].author.login,
          path: .comments.nodes[0].path,
          line: .comments.nodes[0].line,
          body: .comments.nodes[0].body,
          is_outdated: .isOutdated
        })'
    ;;

  reply)
    PR=${1:?PR required}
    CID=${2:?comment ID required}
    BODY=${3:?body file required}
    [[ -f "$BODY" ]] || { echo "body file not found: $BODY" >&2; exit 1; }
    gh api -X POST \
      "/repos/$OWNER/$REPO/pulls/$PR/comments/$CID/replies" \
      -F body=@"$BODY" \
      > /dev/null
    ;;

  resolve)
    TID=${1:?thread ID required}
    gh api graphql -f query="
      mutation {
        resolveReviewThread(input: {threadId: \"$TID\"}) {
          thread { isResolved }
        }
      }
    " > /dev/null
    ;;

  request-review)
    PR=${1:?PR required}
    REVIEWER=${2:?reviewer required}
    gh api -X POST \
      "/repos/$OWNER/$REPO/pulls/$PR/requested_reviewers" \
      --input - >/dev/null <<EOF
{"reviewers": ["$REVIEWER"]}
EOF
    ;;

  *)
    usage
    ;;
esac

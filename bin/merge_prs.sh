#!/usr/bin/env bash
set -euo pipefail

OWNER="${OWNER:?Set OWNER}"
REPO="${REPO:?Set REPO}"
BASE_BRANCH="${BASE_BRANCH:-main}"

git fetch origin
git checkout "$BASE_BRANCH"
git pull origin "$BASE_BRANCH"

git branch -D _tmp_deploy 2>/dev/null || true
git checkout -b _tmp_deploy

# List open PR numbers
prs=$(gh pr list --repo "$OWNER/$REPO" --state open -L 1000 --json number | jq -r '.[].number')

for pr in $prs; do
  # Prefer checks API; fallback to commit status API
  state=$(gh pr checks "$pr" --repo "$OWNER/$REPO" --json state --jq '.[0].state // "UNKNOWN"' 2>/dev/null || echo "UNKNOWN")
  if [[ "$state" == "UNKNOWN" || "$state" == "null" ]]; then
    head_sha=$(gh pr view "$pr" --repo "$OWNER/$REPO" --json headRefOid --jq '.headRefOid')
    state=$(gh api repos/"$OWNER"/"$REPO"/commits/"$head_sha"/status --jq '.state // "UNKNOWN"' 2>/dev/null || echo "UNKNOWN")
  fi

  if [[ "$state" == "SUCCESS" || "$state" == "success" ]]; then
    echo "✅ Merging PR #$pr"

    pr_info=$(gh api repos/$OWNER/$REPO/pulls/$pr --jq '{owner: .head.repo.owner.login, repo: .head.repo.name, ref: .head.ref}')
    fork_owner=$(echo "$pr_info" | jq -r '.owner')
    fork_repo=$(echo "$pr_info" | jq -r '.repo')
    fork_ref=$(echo "$pr_info" | jq -r '.ref')

    git branch -D "$fork_owner-$fork_ref" 2>/dev/null || true
    git fetch "https://github.com/$fork_owner/$fork_repo.git" "$fork_ref:$fork_owner-$fork_ref"
    git merge --no-edit --allow-unrelated-histories "$fork_owner-$fork_ref"
  else
    echo "❌ Skipping PR #$pr (state=$state)"
  fi
done

echo "🎉 All passing PRs merged into _tmp_deploy"
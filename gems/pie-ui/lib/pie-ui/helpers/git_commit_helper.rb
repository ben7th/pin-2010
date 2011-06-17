module GitCommitHelper
  def show_commit_stat(commit)
    stats = commit.stats
    additions = stats.additions | stats.files.count
    deletions = stats.deletions
    total = additions + deletions

    if additions + deletions <=6
      add = additions
      del = deletions
    else
      add = additions * 6 / total
      del = deletions * 6 / total
    end
    render 'layouts/haml/commit',:commit=>commit,:add=>add,:del=>del
  end
end

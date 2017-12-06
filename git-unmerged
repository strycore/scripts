#!/usr/bin/env ruby

require 'rubygems'

gem 'term-ansicolor', '>=1.0.5'
require 'term/ansicolor'

class GitCommit
  attr_reader :content

  def initialize(content)
    @content = content
  end

  def sha
    @content.split[1]
  end

  def to_s
    `git log --pretty=format:"%h %ad %an - %s" #{sha}~1..#{sha}`
  end

  def unmerged?
    content =~ /^\+/
  end

  def equivalent?
    content =~ /^\-/
  end
end

class GitBranch
  attr_reader :name, :commits

  def initialize(name, commits)
    @name = name
    @commits = commits
  end

  # Returns origin from origin/some/branch/here
  def repository
    name.split("/", 2).first
  end

  # Returns some/branch/here from origin/some/branch/here
  def branch_name
    name.split("/", 2).last
  end

  def unmerged_commits
    commits.select{ |commit| commit.unmerged? }
  end

  def equivalent_commits
    commits.select{ |commit| commit.equivalent? }
  end

end

class GitBranches < Array
  def self.clean_branch_output(str)
    str.split(/\n/).map{ |e| e.strip.gsub(/\*\s+/, '') }.reject{ |branch| branch =~ /\b#{Regexp.escape(UPSTREAM)}\b/ }.sort
  end

  def self.local_branches
    clean_branch_output `git branch`
  end

  def self.remote_branches
    clean_branch_output `git branch -r`
  end

  def self.load(options)
    git_branches = new
    branches = if options[:local]
      local_branches
    elsif options[:remote]
      remote_branches
    end

    branches.each do |branch|
      raw_commits = `git cherry -v #{UPSTREAM} #{branch}`.split(/\n/).map{ |c| GitCommit.new(c) }
      git_branches << GitBranch.new(branch, raw_commits)
    end
    git_branches
  end

  def unmerged
    reject{ |branch| branch.commits.empty? }.sort_by{ |branch| branch.name }
  end

  def any_missing_commits?
    select{ |branch| branch.commits.any? }.any?
  end
end

class GitUnmerged
  VERSION = "1.1"

  include Term::ANSIColor

  attr_reader :branches

  def initialize(args)
    @options = {}
    @branches_to_prune = []
    extract_options_from_args(args)
  end

  def load
    @branches ||= GitBranches.load(:local => local?, :remote => remote?)
    @branches.reject!{|b| @options[:exclude].include?(b.name)} if @options[:exclude].is_a?(Array)
    @branches.select!{|b| @options[:only].include?(b.name)} if @options[:only].is_a?(Array)
  end

  def print_overview
    load
    if @options[:exclude] && @options[:exclude].length > 0
      puts "The following branches have been excluded"
      @options[:exclude].each do |branch_name|
        puts "  #{branch_name}"
      end
      puts
    end

    if @options[:only] && @options[:only].length > 0
      puts "The following branches will be compared against:"
      @options[:only].each do |branch_name|
        puts "  #{branch_name}"
      end
      puts
    end

    if branches.any_missing_commits?
      puts "The following branches possibly have commits not merged to #{upstream}:"
      branches.each do |branch|
        num_unmerged = yellow(branch.unmerged_commits.size.to_s)
        num_equivalent = green(branch.equivalent_commits.size.to_s)
        puts %|  #{branch.name} (#{num_unmerged}/#{num_equivalent} commits)|
      end
    end
  end

  def print_help
    puts <<-EOT.gsub(/^\s+\|/, '')
      |Usage: #{$0} [-a] [--upstream <branch>] [--remote] [--prune]
      |
      |This script wraps the "git cherry" command. It reports the commits from all local
      |branches which have not been merged into an upstream branch.
      |
      |  #{yellow("yellow")} commits have not been merged
      |  #{green("green")} commits have equivalent changes in <upstream> but different SHAs
      |
      |The default upstream is 'master' (or 'origin/master' if running with --remote)
      |
      |OPTIONS:
      |  -a   display all unmerged commits (verbose)
      |  --remote (-r)  compare remote branches instead of local branches
      |  --upstream <branch>   specify a specific upstream branch (defaults to master)
      |  --exclude <branch>[,<branch>,...]   specify a comma-separated list of branches to exclude
      |  --only <branch>[,<branch>,...]   specify a comma-separated list of branches to include
      |  --prune  prompts user to delete branches which have no differences with the upstream
      |
      |EXAMPLE: check for all unmerged commits
      |  #{$0}
      |
      |EXAMPLE: check for all unmerged commits and merged commits (but with a different SHA)
      |  #{$0} -a
      |
      |EXAMPLE: use a different upstream than master
      |  #{$0} --upstream otherbranch
      |
      |EXAMPLE: compare remote branches against origin/master
      |  #{$0} --remote (-r)
      |
      |EXAMPLE: delete branches without unmerged commits
      |  #{$0} --prune
      |
      |EXAMPLE: delete remote branches without unmerged commits
      |  #{$0} --remote --prune
      |
      |GITCONFIG:
      |  If you name this file git-unmerged and place it somewhere in your PATH
      |  you will be able to type "git unmerged" to use it. If you'd like to name
      |  it something else and still refer to it with "git unmerged" then you'll
      |  need to set up an alias:
      |      git config --global alias.unmerged \\!#{$0}
      |
      |Version: #{VERSION}
      |Author: Zach Dennis <zdennis@mutuallyhuman.com>
    EOT
    exit
  end

  def print_version
    puts "#{VERSION}"
  end

  def branch_description
    local? ? "local" : "remote"
  end

  def print_specifics
    load

    if branches.any_missing_commits?
      print_breakdown
    else
      puts "There are no #{branch_description} branches out of sync with #{upstream}"
    end
  end

  def print_breakdown
    puts "Below is a breakdown for each branch. Here's a legend:"
    puts
    print_legend
    branches.each do |branch|
      puts
      print "#{branch.name}:"
      if branch.unmerged_commits.empty? && !show_equivalent_commits?
        print "(no unmerged commits"
        if prune?
          print ",", red(" this will be pruned")
          @branches_to_prune << branch
        end
        print ")\n"
      else
        puts
      end
      branch.unmerged_commits.each { |commit| puts yellow(commit.to_s) }

      if show_equivalent_commits?
        branch.equivalent_commits.each do |commit|
          puts green(commit.to_s)
        end
      end
    end
  end

  def print_legend
    load
    puts "  " + yellow("yellow") + " commits have not been merged"
    puts "  " + green("green") + " commits have equivalent changes in #{UPSTREAM} but different SHAs" if show_equivalent_commits?
  end

  def prune
    return unless prune?
    if @branches_to_prune.empty?
      puts "", "There are no branches to prune."
    else
      # Protects Heroku repo's
      rejected_master_branches = @branches_to_prune.reject!{|branch| branch.branch_name =~ /master/}
      puts "", "Are you sure you want to prune the following #{@branches_to_prune.size} branches?", ""
      puts red("(Keep in mind this will remove these branches from the remote repository)") if @remote
      @branches_to_prune.each do |branch|
        puts red(" #{branch.name}")
      end
      puts "(omitting branches named master)" if rejected_master_branches
      puts
      print "y or n: "
      if STDIN.gets=~/y/i
        @branches_to_prune.each do |branch|
          if local?
            `git branch -D #{branch.name}`
          elsif remote?
            puts "pruning: #{branch.branch_name} with 'git push #{branch.repository} :#{branch.branch_name}'"
            `git push #{branch.repository} :#{branch.branch_name}`
          end
        end
        puts "", "Pruned #{@branches_to_prune.size} branches."
      else
        puts "", "Pruning aborted. All branches were left unharmed."
      end
    end
  end

  def prune? ; @options[:prune ] ; end
  def show_help? ; @options[:show_help] ; end
  def show_equivalent_commits? ; @options[:show_equivalent_commits] ; end
  def show_version? ; @options[:show_version] ; end

  def upstream
    if @options[:upstream]
      @options[:upstream]
    elsif local?
      "master"
    elsif remote?
      "origin/master"
    end
  end

  private

  def extract_options_from_args(args)
    if args.include?("--remote") || args.include?("-r")
      @options[:remote] = true
    else
      @options[:local] = true
    end

    @options[:prune] = true if args.include?("--prune")
    @options[:show_help] = true if args.include?("-h") || args.include?("--help")
    @options[:show_equivalent_commits] = true if args.include?("-a")
    @options[:show_version] = true if args.include?("-v") || args.include?("--version")

    if index=args.index("--upstream")
      @options[:upstream] = args[index+1]
    end

    if index=args.index("--exclude")
      @options[:exclude] = args[index+1].split(',')
    end

    if index=args.index("--only")
      @options[:only] = args[index+1].split(',')
    end
  end

  def local? ; @options[:local] ; end
  def remote? ; @options[:remote] ; end
end


unmerged = GitUnmerged.new ARGV
UPSTREAM = unmerged.upstream
if unmerged.show_help?
  unmerged.print_help
  exit
elsif unmerged.show_version?
  unmerged.print_version
  exit
else
  unmerged.print_overview
  puts
  unmerged.print_specifics
  unmerged.prune
end

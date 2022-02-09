#!/usr/bin/ruby
#
#  repository webhook which adds branch protection on the repository which triggered
#    this webhook, then an issue is created @-mentioning the login who created the
#    repository that branch protections were added and lists them in the issue
#
#  This webhook uses Sinatra and Octokit as the primary tools for acting as a webservice
#    and a API tool for working with api.github.com, respectively
#
#  2022-02-08 GitHub Expert Services - WorkOrder #222B56
#

require 'sinatra'
require 'json'
require 'octokit'
require 'netrc'

#log_path = "/tmp/webhk-test.log"
#log = File.open(log_path,"w")
#if log.nil?
#  abort("Could not open #{log_path} for writing")
#end
#log.write("Log opened\n")

client = Octokit::Client.new(:netrc => true)
me = client.login
#log.write("Logged into api.github.com as ", me, "\n")


#
# Repository branch protections
#
repo_br_prots = {
  required_status_checks: {
    strict: true,
    contexts: [] },
  required_pull_request_reviews: {
    required_approving_review_count: 1,
    require_code_owner_reviews: false },
  enforce_admins: false
  }

# issue title doesn't vary
issue_title = "Repo creation protections applied"

#
#  Infinite server loop
#
#while true do

  post '/payload' do

    request.body.rewind
    payload_preparse = request.body.read
    verify_signature(payload_preparse)

    body = JSON.parse(payload_preparse)
    action = body['action']

    if action != "created"
      #log.write(action, " not applicable to this webhook\n")
      next  # top of server loop
    end

    sender_login = body['sender']['login']

    repo = body['repository']
    repo_nwo = repo['full_name']
    repo_url = repo['url']
    repo_defbr = repo['default_branch']
    issues_url = repo['issues_url']
  
#    puts "#{repo_nwo} #{action} by #{sender_login}"
#    log.write(repo_nwo, " ", action, " by ", sender_login, "\n")

    #
    #  Protect the branch with the repo_settings
    #
    repo_prots = client.protect_branch(repo_nwo, repo_defbr, repo_br_prots)

#    log.write(repo_nwo, " protections applied\n")

    #
    # Body of issue in Markdown
    #
    puts "prots in. build issue_body"
    issue_body = "Hey @" + sender_login + "!\n" + \
                 repo_nwo + " was just created and the following protections applied:\n\n" + \
                 repo_prots.inspect

    puts "body ready for issue creation"
    issue_details = client.create_issue(repo_nwo, issue_title, issue_body)
    puts "issue created"
    nil
    
    #log.write(repo_nwo, "Repo creation branch protection issue created: url=", issue_details[:url], "\n")
  
  end

#end  # end of server loop

#log.close

def verify_signature(payload_body)
  signature = 'sha256=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), ENV['WEBHOOK_SECRET'], payload_body)
  return halt 500, "Signatures didn't match!" unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE_256'])
end

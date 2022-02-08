# ExpertSvcsTest
Technical Screener repo

Webhook service that receives repository `created` events, and:
- Applies branch protection, "strict" and "PR review required", on the default branch, usually `main` or `master`
- Creates an _issue_ to @-mention the repo's creator with the repo name-with-owner and the protections in effect

### The exercise solution is implemented in:

- [Ruby](https://www.ruby-lang.org/en/) - General object-oriented script language
- [Sinatra](http://www.sinatrarb.com/) - Web service construct, i.e. accept HTTP requests
- [Octokit](https://github.com/octokit) - Methods to interface with `api.github.com`
- [ngrok](https://ngrok.com/) - Provide tunnel to a public IP address and webserver
- [GitHub Webhooks](https://docs.github.com/en/enterprise-cloud@latest/developers/webhooks-and-events/webhooks/about-webhooks) - Notification technology to automate customizations to repository creation for the [flyingcattails](https://github.com/flyingcattails) organization

### Implementation on GitHub.com
- [Create/Manage/Edit Org Webhook](https://github.com/organizations/flyingcattails/settings/hooks/341949195)

### Implementation on local server
1. SSH into, or open a terminal window on, the server
2. Start ngrok: `ngrok http 4567`
3. SSH into, or open a second terminal window on, the server
4. Start the webservice: `/home/dparrish/bin/repoprot-webhk.rb`

### Questions or Problems:
Contact GitHub Expert Services via your GitHub Account Manager

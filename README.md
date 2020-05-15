# Wazuh's redirections manager

This app is a POC prototype for a redirection manager. It stores the relationships between Wazuh's documentation releases, setting correspondences between URLs to make the branch selector work and avoid 404 errors.

It aims to simplify the mainteinance process by automatizing some tasks, such as recoginizing new and deleted pages between releases, and provide a GUI for specifying relationships between them.

## Requirements

- Ruby 2.7.0
- Rails 6.0

## Installation guide

Clone the repo in your local machine and execute the following commands:

```bash
cd wazu-redirections
bundle
npm install
rails db:migrate
rails s
```

It will launch a live server in your machine. You can see the app live by visiting `localhost:3000`.
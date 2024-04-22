# JoinMy.Party

An interactive party platform where players connect from their smartphones to play in games together.

## Architecture

Each game room has the following architecture (using the game "Prisoner's Dilemma" in this example):

![Game Room Infrastructure](docs/joinmy-party-game-architecture.png)

Since we are using Elixir and each game room is in its own process, this can scale horizontally to easily handle thousands of game rooms running concurrently, and entirely fault tolerant from each other.

## Available Games

Currently, the only game available is Prisoner's Dilemma.

## Start Dev Environment

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start PostgreSQL database with `start-docker-db.sh`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Run in Production

Ready to run in production? Please [check the Pheonix deployment guides](https://hexdocs.pm/phoenix/deployment.html).


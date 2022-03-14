# Watto


Wautils2. This is a rewrite of https://github.com/nova-labs/wild_apricot_python_flask_utils, but since it is mostly ruby that didn't seem like a very good repo to stash this app.

Watto provides an utility interface to the Nova Labs Wild Apricot account for a few custom tasks that we need in the Maker Space. This is primariliy for class instructors and show stewards to manage sign offs.

# Development

Recomend using a ruby version manager such as [RVM](https://rvm.io/) or [rbenv](https://github.com/rbenv/rbenv], but this project doesn't have any preferences.

Clone the repo, create a `.env` file with the necessary envrionment variables (see `.env-example` for the options).

Then to install the dependencies and setup the database:

```
./bin/setup
```

Then to get a local web server:

```
./bin/server
```

Running the tests:

```
./bin/rspec
```

# Integration Wild Apricot

This app doesn't make much sense without a Wild Aprocot account.

## Auth

Authentication is done via [OAuth with Wild Apricot](https://gethelp.wildapricot.com/en/articles/200-single-sign-on-service).

## Data Sync

The following models are kept in sync with Wild Apricot

| Rails Model           | Wild Apricot Model | Description                                                                     |
| --------------------- | ------------------ | ------------------------------------------------------------------------------- |
| User                  | Contact            | Contact or member.                                                              |
| Field                 | Field              | Field description and type                                                      |
| FieldUserValue        | Value              | A users value for a field, may be multiple for a field if it is MultipleChoice. |
| FieldAllowedValue     | AllowedValues      | Allowed options for a Field, e.g. multiple choice options.                      |
| Event                 | Event              | Event with time and place.                                                      |
| EventRegistration     | EventRegistration  | A person registered for an event.                                               |

Sync of these models can happen via a command line task:

```
./bin/rails wa:sync
```

Or individual resource collections:

```
./bin/rails wa:users
./bin/rails wa:events
```

To see all the options run:

```
./bin/rails -T
```


# License

MIT. See [LICENSE](LICENSE).

-----

"Mind tricks don't work on me." -- Watto


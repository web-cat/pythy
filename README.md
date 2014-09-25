Pythy -- The Cloud-Based IDE for Novice Python Programmers
==========================================================

Pythy is a web-based programming environment for Python that
**eliminates software-related barriers to entry** for
novice programmers, such as installing the language runtime and IDE
and properly configuring other dependencies. Within seconds, students can
begin **writing code, watch it execute, debug it, and access support materials and tutorials**,
all from within the familiar context of their **web browser**.  
For more information please see the [slides](http://sofia.cs.vt.edu/cta-mediacomp/presentation.pdf) and the [paper](http://dl.acm.org/citation.cfm?id=2538977)

Setup Instructions
------------------
### Dependencies

1. Ruby
2. The Ruby on Rails framework. 
3. Mysql client and server. (For linux install the dev packages also.)
4. A JavaScript runtime (Ex: Node.js)
5. The Redis server.

(For an ubuntu installation see [Setup Ruby on Rails on Ubuntu](https://gorails.com/setup/ubuntu/14.04))

### Linux
1.  Clone the git repository. `git clone https://github.com/web-cat/pythy.git`
2.  Go into the newly created pythy directory. `cd pythy`
3.  Install the dependencies. `bundle install`
4.  Create a database configuration file at `config/database.yml`. 
    The adapter must be mysql2 as some of the sql statements will not work
    otherwise. [Sample configuration file](#sample-database-configuration-file).
5.  Create the database. `bundle exec rake db:create`
6.  Load the schema into the database. `bundle exec rake db:schema:load`
7.  Seed the database with the initial values. `bundle exec rake db:seed`
8.  Run the server. `rails server`
9.  If the server is running locally, visit [http://localhost:3000](http://localhost:3000), else, visit the corresponding url.
10. To be able to use the grading feature, you need to have
[sidekiq](https://github.com/mperham/sidekiq) running on the server.
`bundle exec sidekiq`. The sidekiq dashboard can be accessed at /sidekiq. 

#### Running the tests
The tests are located in the `spec` directory. To run them, first prepare the
test database by running the commands
```
bundle exec rake db:test:prepare
bundle exec rake db:seed RAILS_ENV=test
```

Preparing the test database is a one-time operation.  

Now, the tests can be run using the command  
`bundle exec rspec`

Running the tests generates a coverage report 
(using [simplecov](https://github.com/colszowka/simplecov))
that is stored in the `coverage` directory.
Open the `index.html` file in a web browser to view the test coverage.
 
### Sample Database Configuration File


```
	development:
    		adapter: mysql2
    		encoding: utf8
    		database: dev_pythy
    		pool: 5
    		username: <your mysql username>
    		password: <your mysql password>
	test:
    		adapter: mysql2
    		encoding: utf8
    		database: test_pythy
    		pool: 5
    		username: <your mysql username>
    		password: <your mysql password>
```

Objectives and Plans
--------------------

+   Design as a **modern, AJAX-powered Web 2.0 application**.
+   Avoid duplicating the traditional IDE model of a project tree,
    overfull toolbars, and multiple docked views. Instead, take advantage
    of the existing **web browser document and tab model**
    that students are already accustomed to.
+   Store student code in **Git** repositories; adopt an
    aggressive auto-saving policy to collect fine-grained data about
    novices' programming habits and to avoid data loss.
+   Evaluate Javascript-based Python implementations
    (<a href="http://www.skulpt.org">Skulpt</a>,
    <a href="http://pyjs.org">Pyjs</a>,
    <a href="http://pyjaco.org/about">Pyjaco</a>, others?) to
    compile/run/debug code **entirely on the client**,
    eliminating server-round-trip latency&mdash;also to enable
    **highly interactive/graphical assignments** that
    render live in the browser; consider supporting server-side
    Python/Jython as well.
+   Explore integrating an open-source interactive textbook directly
    into the application, such as
    <a href="http://interactivepython.org/courselib/static/thinkcspy/index.html">How to Think Like a Computer Scientist: Interactive Edition (Using Pyth
on 3.x)</a>
    (which already uses Skulpt to run the embedded exercises).


Funding
-------

We would like to acknowledge those who have graciously provided funding for
our initial work on Pythy&mdash;the **SIGCSE Special Projects Grants**
board, which provided undergraduate student wages support for Pythy's
initial development, and the **Virginia Tech Student Engineering Council,**
which provided support for purchasing the server hardware for Pythy's
deployment at Virginia Tech.

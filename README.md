Pythy -- The Cloud-Based IDE for Novice Python Programmers
==========================================================

Pythy is a web-based programming environment for Python that
*eliminates software-related barriers to entry* for
novice programmers, such as installing the language runtime and IDE
and properly configuring other dependencies. Within seconds, students can
begin *writing code, watch it execute, debug it, and access support materials and tutorials,*
all from within the familiar context of their *web browser.*


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

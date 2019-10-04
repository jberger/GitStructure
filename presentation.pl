use Mojolicious::Lite;

plugin 'RevealJS';

any '/' => { template => 'index', layout => 'revealjs' };

#XXX example: https://github.com/ServerCentral/SCOPE/pull/124

app->start;

__DATA__

@@ index.html.ep

<style>
  .reveal pre code { padding: 20px }
  code.hljs.inline {
    display: initial;
    font-size: 80%;
    margin: 0 10px 0 10px;
  }
</style>

%= markdown_section begin
## Learn Git By Structure
% end

%= markdown_section begin
Does Git seem

* Strange?
* Mystifying?
* Opaque?
% end

%= markdown_section begin
Git is entirely driven by its structure

* commit graph
* file backed
% end

%= markdown_section begin
The graph is built of these three concepts

* digests
* objects
* references
% end

%= markdown_section begin
## Preface: Cryptographic Digest Functions
% end

%= markdown_section begin
## Digest Functions:

> compute a meaningful representative identifier from a larger set of data
% end

%= markdown_section begin
## This Is Not Compression

* Not reversible
* Not one-to-one
* Possible duplicates
* ... but those "collisions" are rare
% end

%= markdown_section begin
For example

```shell
$ echo 'hello' | perl -MList::Util=sum -nE 'say sum map { ord } split //'
542
```
% end

%= markdown_section begin
## A Good Digest Function

- Large change in output for small input (easy to see)
- Hard to predict what change will do (hard to fake)
% end

%= markdown_section begin
Not easy to see

```shell
$ echo 'hello' | perl -MList::Util=sum -nE 'say sum map { ord } split //'
542
$ echo 'hellp' | perl -MList::Util=sum -nE 'say sum map { ord } split //'
543
```
% end

%= markdown_section begin
Easy to fake

```shell
$ echo 'hello' | perl -MList::Util=sum -nE 'say sum map { ord } split //'
542
$ echo 'hellp' | perl -MList::Util=sum -nE 'say sum map { ord } split //'
543
$ echo 'hdllp' | perl -MList::Util=sum -nE 'say sum map { ord } split //'
542
```
% end

%= markdown_section begin
Luckily we have cryptographic digest functions

```shell
$ echo 'hello' | sha1sum | awk '{print $1}'
f572d396fae9206628714fb2ce00f72e94f2258f
$ echo 'hellp' | sha1sum | awk '{print $1}'
c2e8afc57a12fd9224718c1fa8bbf1b8a02d8390
```
% end

%= markdown_section begin
## What Does This Have To Do With Git?
% end

%= markdown_section begin
> You can disagree with me as much as you want but during this talk, by definition, anybody who disagrees is stupid and ugly.

-- Linus Torvalds

<cite><small><https://www.youtube.com/watch?v=4XpnKHJAok8></small></cite>
% end

<section>
  <p>
    <video data-autoplay>
      <source data-src="linus.mp4" type="video/mp4"></source>
    </video>
  </p>

  <div class="fragment">
    <blockquote>
      If you know the sha1 of the top of tree you can trust every single piece of it.
    </blockquote>

    paraphrased from:
  </div>
  <p>
    <small>
      <a href="https://www.youtube.com/watch?v=4XpnKHJAok8&t=3382">https://www.youtube.com/watch?v=4XpnKHJAok8&t=3382</a>
    </small>
  </p>
</section>

%= markdown_section begin
> If I have those 20 bytes, I can download a git repository from a completely untrusted source and I can guarantee that they didn't do anything bad to it.

-- Linus Torvalds

<cite><small><https://www.youtube.com/watch?v=4XpnKHJAok8></small></cite>
% end

%= markdown_section begin
## Major Takeaway

The commit hash id is an identifier that digests the entire history of the repository up to that point.
% end

%= markdown_section begin
## How does that work?
% end

%= markdown_section begin
## Git Objects

* blob (content, ie file or other metadata)
* tree (collection of blobs and other trees)
* commit
% end

%= markdown_section begin
## Every Object is Identified By Its SHA1 Hash
% end

%= markdown_section begin
## A Commit Is

* tree
* parent(s)
* commit message
* metadata

Identified by _its_ sha1 hash
% end

%= markdown_section begin
## The .git Directory  

* `.git/` contains the entire repository
* the working directory is just your workspace
  - you don't need it
  - used to stage changes
* repo without working files is called "bare"
% end

%= markdown_section begin
### Objects
* live in the `.git/objects` directory of a project
* inspect with 
  - type: `git cat-file -t`
  - content: `git cat-file -p`
% end

%= markdown_section begin
```shell
$ git cat-file -t e3d0802d5961794103c6a8d02f64bf7e1749f3cc
commit
$ git cat-file -p e3d0802d5961794103c6a8d02f64bf7e1749f3cc
tree 2f7e309f3414aa204bf1468b7510567e1cf3233c
parent 7e9f736539c4d2a6dd7f1dccfda4bb77d3cd608a
author Joel Berger <joel.a.berger@gmail.com> 1556634504 -0500
committer Joel Berger <joel.a.berger@gmail.com> 1556634504 -0500

$ git cat-file -t 2f7e309f3414aa204bf1468b7510567e1cf3233c
tree
$ git cat-file -p 2f7e309f3414aa204bf1468b7510567e1cf3233c
100755 blob c0a5f45cff9b2318ee1f3f9da7157addcd23f2a4	Perloku
100644 blob c91114a2f3eae6bfa6cb24a341a5a54186a0ea97	README.pod
100644 blob 041ae46cc95ce3f2e8f52e0df3df422099bf3974	cpanfile
040000 tree 57321dcf90135b3e33e0c18db051316a08435053	ex
100755 blob a88092e7e5489b581a61fa085da70af535f3e80f	presentation.pl
040000 tree 7cde0b756cfd92a349fd41a27f8685bbac982cbc	public
040000 tree 510f6121f6023df413bbbb8f11661e85d55db901	templates

$ git cat-file -t c0a5f45cff9b2318ee1f3f9da7157addcd23f2a4
blob
$ git cat-file -p c0a5f45cff9b2318ee1f3f9da7157addcd23f2a4
#!/bin/sh
./presentation.pl daemon -l http://*:$PORT -m production
```
% end

%= markdown_section begin
### The Commit 
* is named by its digest
* contains data that refers to other objects by digest
* at each level each digest can be verified
* therefore: 

<blockquote class="fragment">
  The commit hash id is an identifier that digests the entire history of the repository up to that point.
</blockquote>
% end

%= markdown_section begin
Always using SHAs to refer to objects is annoying, so ... 
% end

%= markdown_section begin
## ... We Have References

* branches
* tags
* HEAD
% end

%= markdown_section begin
### Refs
* live in the `.git/refs` directory of a project
* inspect with `git show-ref`
* or just `cat` the file contents
% end

%= markdown_section begin
## Branches

* have no content of their own
* simply a pointer that
  - points to a commit
  - moves as commits are added
* lives in `.git/refs/heads`
% end

%= markdown_section begin
## The Special HEAD Rereference

* pointer to the current branch (thus current commit)
* lives in `.git/HEAD`
% end 

%= markdown_section begin
## Tags

* special type of object
* contains some additional info
  - message
  - tagger
* points to another object, usually a commit
* lives in `.git/refs/tags`
% end

%= markdown_section begin
## Object Lifetime

Objects will live in `.git/objects` as long as

* some other object references it
* timeout expires (usually 90 days)
% end

%= markdown_section begin
## Reflog

You can see every object created via `git reflog`.

```shell
$ git reflog
a59bf6512 (HEAD -> log_context, origin/log_context) HEAD@{0}: reset: moving to origin/log_context
daf1ec7d5 HEAD@{1}: checkout: moving from master to log_context
2a7466423 (origin/master, origin/HEAD, master) HEAD@{2}: pull: Fast-forward
921fd5ce9 HEAD@{3}: pull: Fast-forward
181971ff7 HEAD@{4}: checkout: moving from getopt_return to master
a75edf2da (origin/getopt_return, getopt_return) HEAD@{5}: commit: normalize the getopt tests
b9672b0ad HEAD@{6}: rebase finished: returning to refs/heads/getopt_return
b9672b0ad HEAD@{7}: rebase: use ok() instead of is() to check for successful option parsing
e021a2815 HEAD@{8}: rebase: return result of GetOptionsFromArray in getopt().
```

These expire after a shorter time (usually 30 days)
% end


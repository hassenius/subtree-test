# subtree-test

Demonstrate the use of git subtree feature

## Setup

subtree-test is the base repository, and files can be added here independently. This README belongs to the root repository

Additional (external) repositories are added using the git subtree feature:

For example

```
$ git remote add log-queue git@github.com:egymgmbh/log-queue.git
$ git subtree add --prefix log-queue log-queue master
```

This will create a new subdirectory for all repositories that are added.
It is possible to group repositories in subdirectories, by using the following syntax

``` 
$ git subtree add --prefix healthcheckapi/rubyhealthcheck git@github.com:sportngin/okcomputer.git master
```

Both approaches are present in this "umbrella" repo



### Pros

- All repositories are downloaded with a single ```git clone``` command

### Cons

- It is hard to maintain a reference to the author and owner of the original repositories that are added
- It is hard to maintain a tidy structure
- When downloading the root repository it may not always be desired to download all the "linked" repositories
- The git commit history/messages can look a bit messy and hard to follow
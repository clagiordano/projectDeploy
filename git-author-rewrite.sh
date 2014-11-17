#!/bin/bash

git filter-branch --env-filter '
 
an="$GIT_AUTHOR_NAME"
am="$GIT_AUTHOR_EMAIL"
cn="$GIT_COMMITTER_NAME"
cm="$GIT_COMMITTER_EMAIL"

OLD_MAIL="claudio.giordano@wyscout.com"
NEW_NAME="Claudio Giordano"
NEW_MAIL="claudio.giordano@autistici.org"
 
if [ "$GIT_COMMITTER_EMAIL" = "$OLD_MAIL" ]
then
    cn="$NEW_NAME"
    cm="$NEW_NAME"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_MAIL" ]
then
    an="$NEW_NAME"
    am="$NEW_MAIL"
fi
 
export GIT_AUTHOR_NAME="$an"
export GIT_AUTHOR_EMAIL="$am"
export GIT_COMMITTER_NAME="$cn"
export GIT_COMMITTER_EMAIL="$cm"
'

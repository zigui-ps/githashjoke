# githashjoke
## Usage

Store funny hash value in your git log!!

## Require

nvidia GPU && nvidia driver

## How to use

1. Make a commit
2. ```bash message.sh | ${cuda executable}``` in your git directory. (fill ${} correctly)
3. ```GIT_COMMITTER_DATE="${commit date}" git commit --amend -m "${message part of 2's output}"``` (fill ${} correctly)

## Example

```
zigui@zigui-Surface-Book-2:~/githashjoke$ git commit -m "add executable"
[master 69f9749] add executable
 1 file changed, 0 insertions(+), 0 deletions(-)
 create mode 100755 cuda
zigui@zigui-Surface-Book-2:~/githashjoke$ bash message.sh | ./cuda 
commit 262tree a3891e4fee296e7dad43e5b9ab6c98273267dbae
parent 00000000c50369e51bb9896d2004a3f9aafb041f
author ziguips <zigui_@naver.com> 1559653404 +0900
committer ziguips <zigui_@naver.com> 1559653404 +0900

add executable                               ENLIGCNNB@@@@@@@zigui@zigui-Surface-Book-2:~/githashjoke$ GIT_COMMITTER_DATE="1559653404" git commit --amend -m "add executable                               ENLIGCNNB@@@@@@@"
[master 000000001] add executable                               ENLIGCNNB@@@@@@@
 Date: Tue Jun 4 22:03:24 2019 +0900
 1 file changed, 0 insertions(+), 0 deletions(-)
 create mode 100755 cuda
```

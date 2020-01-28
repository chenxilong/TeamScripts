# Submit a job
- qsub -pe thread 1 -cwd -R y -q long.q
- qsub -pe thread 1 -cwd -R y -q short.q
# job stat
- qstat
# job stat of a queue
- qhost -j | grep long.q
- qhost -j | grep short.q
# cluster stat of a queue
- qstat -F vf,num_proc -q long.q
# del job
- qdel <id>
- qdel -u <user name>

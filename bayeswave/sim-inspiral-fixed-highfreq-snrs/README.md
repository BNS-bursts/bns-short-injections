# Injection results
## Workflow setup
Run the workflow generation script in a loop ove files on disk like:
```
[jclark@ldas-osg] $ while read p; do echo $p; ./run_pipe $p; done < bauswein_h5_list.txt 
```

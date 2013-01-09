The lib/tasks/indexing path is just a holding area for old rake tasks that predated the move to a separate
Catalog application. All the tasks in here should have a namespace that begins with "xxx_" and should not be
run.

Either the functionality of these has been superceded by a new version of the rake task, or the task was a
one time task that doesn't need to be updated, or it is a rarely used task that may need to be revisited in
the future.

The tasks in here MAY be a good example of how to handle a particular task.

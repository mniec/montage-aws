# utils

module MontageAWS


autoload :Cmd, 'montage_aws/utils/cmd'
autoload :Montage, 'montage_aws/utils/montage_helper'
autoload :EC2Utils, 'montage_aws/utils/ec2_utils'

# factories
autoload :TaskFactory, 'montage_aws/factory/task_factory'
autoload :CmdFactory, 'montage_aws/factory/cmd_factory'
autoload :ActivityFactory, 'montage_aws/factory/activity_factory'


autoload :Task, 'montage_aws/tasks/task'
autoload :CmdTask, 'montage_aws/tasks/cmd/cmd_task'
autoload :ActivityTask, 'montage_aws/tasks/activities/activity_task'

# cmd
autoload :Provision, 'montage_aws/tasks/cmd/provision'
autoload :Worker, 'montage_aws/tasks/cmd/worker'
autoload :EC2Provider, 'montage_aws/tasks/cmd/ec2_provider'
autoload :StartEC2DeciderAndProvider, 'montage_aws/tasks/cmd/ec2_provider'
autoload :Decider, 'montage_aws/tasks/cmd/decider'
autoload :Compute, 'montage_aws/tasks/cmd/compute'
autoload :StartEC2Worker, 'montage_aws/tasks/activities/start_ec2_worker'

# activities
autoload :Project, 'montage_aws/tasks/activities/project'
autoload :Merge, 'montage_aws/tasks/activities/merge'
autoload :TerminateEc2Instances, 'montage_aws/tasks/activities/terminate_ec2_instances'


end
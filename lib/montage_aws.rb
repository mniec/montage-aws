# utils

module MontageAWS


autoload :Cmd, 'montage_aws/utils/cmd'
autoload :Montage, 'montage_aws/utils/montage_helper'
autoload :EC2Utils, 'montage_aws/utils/ec2_utils'

# factories
autoload :Tasks, 'montage_aws/factory/tasks'


autoload :Task, 'montage_aws/tasks/task'
autoload :CmdTask, 'montage_aws/tasks/cmd/cmd_task'
autoload :ActivityTask, 'montage_aws/tasks/activities/activity_task'

# cmd
autoload :Provision, 'montage_aws/tasks/cmd/provision'
autoload :Worker, 'montage_aws/tasks/cmd/worker'
autoload :InfrastructureProvisioner, 'montage_aws/tasks/cmd/infrastructure_provisioner'
autoload :Decider, 'montage_aws/tasks/cmd/decider'
autoload :Compute, 'montage_aws/tasks/cmd/compute'
autoload :StartEC2Worker, 'montage_aws/tasks/activities/start_ec2_worker'

# activities
autoload :Project, 'montage_aws/tasks/activities/project'
autoload :Merge, 'montage_aws/tasks/activities/merge'


end
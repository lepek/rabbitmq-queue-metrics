PROJECT = rabbitmq_queue_metrics
PROJECT_DESCRIPTION = RabbitMQ queue metrics plugin
PROJECT_MOD = rabbit_queue_metrics_app

current_rmq_ref = rabbitmq_v3_9_10

define PROJECT_APP_EXTRA_KEYS
	{broker_version_requirements, ["3.9.10", "3.9.10"]}
endef

define PROJECT_ENV
[]
endef

DEPS = rabbit_common rabbit cowboy rabbitmq_management jsx rabbitmq_message_timestamp
TEST_DEPS = rabbitmq_ct_helpers rabbitmq_ct_client_helpers

DEP_EARLY_PLUGINS = rabbit_common/mk/rabbitmq-early-plugin.mk
DEP_PLUGINS = rabbit_common/mk/rabbitmq-plugin.mk

# FIXME: Use erlang.mk patched for RabbitMQ, while waiting for PRs to be
# reviewed and merged.

ERLANG_MK_REPO = https://github.com/rabbitmq/erlang.mk.git
ERLANG_MK_COMMIT = rabbitmq-tmp

include rabbitmq-components.mk
include erlang.mk

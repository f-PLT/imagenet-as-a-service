import nox


@nox.session()
def check(session):
    """Lint the code using pylint."""
    session.run("pylint", "imagenet_service", "tests")


@nox.session()
def fix(session):
    """Autoformat code using isort and black."""
    session.run("isort", "imagenet_service", "tests")
    session.run("black", "imagenet_service", "tests")


# Specify the dependencies required for both linting and formatting sessions
nox.options.sessions = ["fix", "check"]
nox.options.reuse_existing_virtualenvs = True

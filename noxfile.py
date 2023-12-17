import nox


@nox.session()
def check(session):
    """Lint the code using pylint."""
    session.run("pylint", "imagenet_service", "tests", external=True)


@nox.session()
def fix(session):
    """Autoformat code using isort and black."""
    session.run("isort", "imagenet_service", "tests", external=True)
    session.run("black", "imagenet_service", "tests", external=True)


@nox.session()
def test(session):
    session.run("pytest", external=True)


# Specify the dependencies required for both linting and formatting sessions
nox.options.sessions = ["fix", "check", "test"]
nox.options.reuse_existing_virtualenvs = True

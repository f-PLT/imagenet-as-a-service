import os


def get_resource_path(filename):
    """Get the absolute path to a resource file in the resources directory."""
    test_dir = os.path.dirname(__file__)
    return os.path.join(test_dir, filename)

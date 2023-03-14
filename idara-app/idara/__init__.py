import os

import click
import sys
from flask import Flask
from werkzeug.utils import import_string

def create_app(test_config=None):
    """Create and configure an instance of the Flask application."""
    app = Flask(__name__, instance_relative_config=True)

    # lecture du fichier de configuration
    app.config.from_envvar('IDARA_SETTINGS')
    # for key, value in app.config.items():
    #     click.echo(f"{key}: {value}")
       
    if app.config['TRACE']:
        click.echo("create_app:" + __name__)
        click.echo("SQLALCHEMY_DATABASE_URI is: " + app.config["SQLALCHEMY_DATABASE_URI"])

    @app.route("/hello")
    def hello():
        return "Hello, World!"

    # register the database commands
    from idara import db

    db.init_app(app)

    # apply the blueprints to the app
    #from idara import auth, blog, profile

    #app.register_blueprint(auth.bp)
    #app.register_blueprint(blog.bp)
    #app.register_blueprint(profile.bp)


    # make url_for('index') == url_for('blog.index')
    # in another app, you might define a separate main index here with
    # app.route, while giving the blog blueprint a url_prefix, but for
    # the tutorial the blog will be the main index
    app.add_url_rule("/", endpoint="index")

    return app

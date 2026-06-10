# Copyright (c) 2026 mingju.xu (xumj1125@live.com). All rights reserved.
# Licensed under the GNU General Public License v3.0.

FROM python:3.9-slim
RUN useradd --create-home appuser
WORKDIR /home/appuser/app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
RUN chown -R appuser:appuser /home/appuser/app

USER appuser

EXPOSE 5000
CMD ["python", "app.py"]

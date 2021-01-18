FROM debian:buster-slim

RUN uname -m 
RUN arch
RUN dpkg --print-architecture
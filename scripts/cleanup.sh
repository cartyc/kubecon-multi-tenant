#!/bin/bash

kind delete cluster --name dev
kind delete cluster --name qa
kind delete cluster --name master
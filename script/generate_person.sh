#!/bin/bash


cd ..
rails generate scaffold Person firstname:string middlename:string lastname:string title:string sex:string salutation:string password:string roles:integer status:integer


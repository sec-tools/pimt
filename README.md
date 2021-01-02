# pimt

## what it does
pimt is a **p**ublic **i**frastructure **m**onitoring **t**ool (pronounced PIM-tee). It queries common recon tools for publicly available data regarding particular organizations based on the domains and keywords provided. It is not meant to provide complete coverage for every external asset that belongs to a company as attackers usually do not have this detailed info or mapping either. One can use it to paint some sort of picture of what external attackers may be looking at, the changes occuring over time and insight for how to further harden the perimeter. The key idea being to provide valuable data to red teams as well as additional monitoring capabilities for defenders.

## how it works
It feeds a single or list of domains and/or keywords to a handful of recon tools. These tools may query known caches for subdomains, do DNS lookups, append different combinations to find cloud storage buckets, etc. You can choose to do a quick single run to just produce the artifacts, or do a run every X seconds, which will enable comparisons of the previous run's results with the current run and various diff artifacts (raw and annotated text, optional json, etc) will be produced if anything changed.

This lets you discover changes such as...

- Additional subdomains have been registered and are now publicly known
- Cloud resources, such as a new S3 buckets, have been claimed and may be in use
- New TLS certificates have been issued
- Services like SSH or RDP are now listening for connections on hosts to which you've subscribed

**Note: the port change feature is not enabled by default and must be explicitly turned on via the CLI. It uses masscan to perform a fast port scan of the host(s) you specify. Only scan IPs that you own yourself or are otherwise authorized to scan. This disclaimer of no liability goes along with usage of this tool and you assume full responsibility for your own actions.**

You can run it as a standalone script or in a docker container. If standalone, just make sure all the recon tools are installed and located in /opt. If using the Dockerfile, it will do all this for you.

## why it is valuable
If you’re a company that is security-conscious, it’s pretty useful to see public changes before potential attackers do. If you’re a red teamer, this data can be valuable leading up to an engagement. If you’re a defender, you want to evaluate new data coming in and know about possible risks that anyone who’s looking could find. This data is valuable and notifications of such events can be used to determine if new potential security risks have just occured.

- Sub-domain called **test-internal.XXXXXXXX.com** was found
  - What is that? Is it some dangling test instance that the dev forgot to terminate? Does it have auth?

- New S3 buckets named **XXXXXXXX-backup** and **YYYY-assets** were found
  - Are the ACL'd as public or "authenticated users"? Who created them? What's in the backups one? Is someone bucket squatting?

- A bunch of new certs were issued that include **YYYYYYYY-com** in the domain name and also some new legit unknown subdomains
  - New phishing campaign? New products launching that we haven't heard of yet?

- SSH ports were just opened on a few different hosts that we're monitoring
  - Was this intended? Should direct shell access be allowed to these hosts?

Just want to see the artifacts produced for a given domain? Use **quick mode (-q)** and only a single run will be performed, no diffs, and both the clean and annotated run files will be in the data/ folder.

## usage
To get started, either build the dockerfile (easy) or install the recon tools in /opt and dependencies manually (takes more time). Then run either the container named **pimt** or if using the package without docker, run shell script **./pimt.sh** and the **./pimtweb.py** web server for browsable access to artifacts.

The following are examples of how to use pimt.

### standalone
**read domains and keywords from files and query every 60 seconds**
```
> cat domains.txt
a.bc.com
xy.zcorp.net
somethingsomethings.com
```

```
> cat keywords.txt
sss
abccorp
zcorp
```

```
> pimt.sh -T domains.txt -K keywords.txt -s 60
```

**provide only keywords from command line and query every 10 seconds**
```
> pimt.sh -k samsung,samsungcorp -s 60
```

**query a target domain every 5 minutes and send diffs to an email (with debug output)**
```
> pimt.sh -t a.b.c.1.2.3.com -s 300 -ef verified@email.ses -et to@ema.il
```

**do a quick run for artifacts only (single run, no diffing)**
```
> pimt.sh -q -t a.b.c.1.2.3.com
```

**disable specific recon tools**
```
> pimt.sh -t a.b.c.1.2.3.com -s 60 -DBUCKETSTREAM -DCLOUDENUM
```

**only run with keywords (disables tools that require target domains)**
```
> pimt.sh -K keywords.txt -s 60
```

**checking port changes for a single IP only**
```
> pimt.sh -s 60 -p 11.22.33.44
```

**checking port changes for a list of IPs + keywords*
```
> pimt.sh -s 60 -k xyzcorp -P ips.txt
```

### docker
**build the image**
```
> docker build -t pimt -f docker/pimt.Dockerfile .
```

**minify image with [docker-slim](https://dockersl.im)**

TBD

**run the image (eg. debugging on, target=wowzainc, disable a particular tool: bucket-stream)**
```
> docker run -it pimt -d -s 5 -DBUCKETSTREAM -t wowzainc.com -k wowzainc
```

**run without AWS creds (no ses / email)**
```
> docker run -it pimt -s 60 -k testing
```

**enable JSON output**
```
> docker run -it pimt -s 60 -k testing -j
```

**run with SES support (if enabled, can send diffs as email notifications)**
```
> docker run -it -v "$HOME/.aws:/home/pimt/.aws:ro" pimt -d -s 5 -ef verified@email.ses -et to@ema.il -k testing
```

**run with support for target and keyword FILES**
```
> docker run -it -v "/tmp/test:/files" pimt -d -s 5 -T /files/targets.txt -K /files/keywords.txt
```

**run with support for target and keyword FILES and expose web server (network interface)**
```
> docker run -it -v "/tmp/test:/files" -p 8080:8080 pimt -s 5 -T /files/targets.txt -K /files/keywords.txt
```

**do basically everything**
```
docker run -it -v "$HOME/.aws:/home/pimt/.aws:ro" -p 8080:8080 pimt -d -j -s 5 -ef verified@email.ses -et to@ema.il -t testing
```

## deps
These are installed automatically if you build the container from the provided dockerfile. Otherwise you if want to run pimt locally without docker, you'll need to make sure they are installed and the recon tools (see dockerfile for current list of which tools have been onboarded) are in the /opt directory and in your local PATH.

### standalone

- bash
- diff
- jq
- tr
- sed
- awscli (email support only)
- masscan (port checking only)
- misc linux tools...
- recon tools (see Dockerfile for a list of what's installed)

### web server
```
> pip install -r requirements.txt
```

## debugging

**debug flags**

```
> pimt.sh -s 60 -k test123 -d
> pimt.sh -s 60 -k test123 -dd (double debug!)
```

**look around inside the container**
```
> docker exec -it [pimt-container-id] bash
```

Note: if you expose the webserver, you can use it to dig around the data/ and diff/ directories.

## misc notes
### email feature
Pimt uses AWS SES for email functionality. If you'd like to get email alerts with the diffs as content when changes occur, setup SES and verify the from email address, attach the appropriate SES policy to a user, do an aws configure to setup creds and you should be good to go. This will work fine in the "SES Sandbox" if you specify the *same email* for the from and to addresses, to send alerts to yourself, but if you want to send emails from the same address but *to different addresses*, then you'll need to request approval on the AWS console to move from Sandbox -> SES Prod.

### port scanning
If you use the ports check feature (-p/-P), the configured ports come from 20 Top Ports [list](https://securitytrails.com/blog/top-scanned-ports).

`21-23,25,53,80,110-111,135,139,143,443,445,993,995,1723,3306,3389,5900,8080`

### web server
This simple flask server is for viewing diffs over the wire and can be used for debugging in general. Just run it and it will listen on port 8080 by default and on the network interface (where it's most useful), not localhost. It's webroot is the local data/ folder, but **there is no auth** so that into account if you run it or expose it in docker (web server runs automatically in entrypoint.sh). Makes it easier to look at diffs and out files than only viewing them on the console.

### other
A tool such as certstream is always gonna produce "new stuff", which may not get reported on the very first run due to the nature of diffing, as there's no previous out file to compare it to. Therefore, nothing has *changed* as far as pimt is concerned. That margin of error probably doesn't matter for most cases, but perhaps noteworthy for future reference. See the FAQ for more details.

## FAQ
- How were the recon tools chosen? Why wasn't toolX or toolY included?

The recon tools chosen must be highly functional, produce consistently reliable results, and be fast enough to not significantly slow down each run.

For example, Altdns was great, but it did not always produce consistent results over longer testing periods. Amass is also an awesome tool, but it's relatively slow compared to the other tools. Each of these should be in your arsenal, but at this time they seem to work better standalone than in a system such as pimt. You don't want to diff the results of something that isn't at all deterministic. For example, if you choose the same domain or keywords to query for over 100 times, you'd want the results to be the same each time right? Otherwise, you're gonna be generating a bunch of useless diffs (and even worst, alerting folks on false positives ... es no bueno). Also, some of the included tools default configuration was changed, data sources narrowed down to the most reliable ones and cloudenum was scoped for AWS-only due to speed preferences, but of course feel free to change this to suit your needs.

- Why was it written in bash and not python, golang, etc?

Good question. The idea started out as "just run a bunch of recon tools in a loop and use the diff command for changes" and other than adding a bunch of CLI options to make customizing runs easier, it hasn't changed much from that. Other than using the awscli for sending SES emails (if enabled), it basically just uses sed, tr, grep, diff, and some cool built-in shell features. Unless the scope of pimt broadens significantly, writing it in a common interpreted language feels like overkill as half of it would be calling exec() on the recon tools and common Linux binaries that already do everything you need. If complexity and artifact processing grows, perhaps it will evolve into another environment for portability and to support more advanced use cases.

- What is enabled by default?

If a target or target list is provided, all tools are enabled. If only keywords are provided, tools that require target domains will be disabled. If port check IP(s) are provided, then port checking will be enabled.

So if you provide domains, but don't want particular tools to run, use -D[TOOLNAME] to disable them individually.

- What guarentees are given with this project?

Absolutely none.

The tools could change or break any time, bash is not super easy to debug so there may be small bugs here and there, but for the most part it should work and maybe after you give it a try, you'll say "neat!" or "ugh" and fork it or build a better one.

- If this tool only checks diffs, but runs tools like bucketstream and certstream which by nature are producing "new stuff", how does that work?

Good question. So mixing tools that produce stable output and those that produce only new stuff is mostly OK, but there is one edge case where something could get missed. If the first run of the tools produces results (eg. new domains from certstream), then it will not produce nor email a diff, because technically there is no diff: there was only initial results. But every run after that, things should work normal. Just the very first run may catch something that is a legit new thing, but not trigger a diff. Since pimt optimizes for "what changed", this subtle issue has been deprioritized for now. So it's 99% effective, I guess.

- Future improvements and stuff?

Output in various formats like sqlite, JSON, talk to cloud dbs etc would be nice depending on the use case. v2 may fit certain scenarios better than others.

**Author**

[Jeremy Brown](mailto:jbrown3264[NOSPAM]gmail)

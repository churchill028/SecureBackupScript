# Backup Script

This Bash script is designed to automate backup operations. It checks drive availability, manages old backups, assesses available space, and creates both incremental and full backups. The script also provides error notifications via logging and email alerts.

## Features

- Checks if the specified drive mount point is available.
- Deletes old backup folders that are older than 9 months.
- Calculates the size of the backup and compares it to available space.
- Creates backup folders based on the current date.
- Creates incremental backups with link-dest to previous backups.
- Sends email notifications for errors and space issues.

## Requirements

- Bash shell environment
- Properly configured `logger` and `mail` commands (for logging and email notifications)
- Access to the paths specified for `mount_point` and `backup_path`

## Usage

1. Replace placeholders like `mount_point` and `backup_path` with actual paths.
2. Set up `logger` and `mail` commands for logging and email notifications.
3. Run the script using the command `bash ./backup_script.sh`.

## Notes

- Make sure to secure your email and system configurations to prevent data leaks.
- Customize the script to fit your environment and backup strategy.

## License

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software...


---

*Disclaimer: Use this script at your own risk. Review and test thoroughly before using it in a production environment.*



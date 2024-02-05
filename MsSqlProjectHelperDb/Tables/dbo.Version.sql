CREATE TABLE [dbo].[Version] (
    [Id]          SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Version]     VARCHAR (50)   NOT NULL,
    [Description] NVARCHAR (500) NOT NULL,
    [Created]     DATETIME2 (2)  CONSTRAINT [DF_Version_Created] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_Version] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Version_Version]
    ON [dbo].[Version]([Version] ASC);


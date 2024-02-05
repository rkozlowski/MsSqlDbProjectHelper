CREATE TABLE [dbo].[Project] (
    [Id]                            SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Name]                          NVARCHAR (200) NOT NULL,
    [NamespaceName]                 VARCHAR (100)  NOT NULL,
    [ClassName]                     VARCHAR (100)  NOT NULL,
    [ClassAccessId]                 TINYINT        NOT NULL,
    [EnumSchema]                    NVARCHAR (128) NULL,
    [StoredProcSchema]              NVARCHAR (128) NULL,
    [GenerateAllStoredProcWrappers] BIT            CONSTRAINT [DF_Project_GenStoredProcWrappersForAll] DEFAULT ((1)) NOT NULL,
    [GenerateAllEnumWrappers]       BIT            CONSTRAINT [DF_Project_GenEnumWrappersForAllTablesInEnumSchema] DEFAULT ((1)) NOT NULL,
    [LanguageId]                    TINYINT        NOT NULL,
    [ParamEnumMappingId]            TINYINT        CONSTRAINT [DF_Project_ParamEnumMapping] DEFAULT ((1)) NOT NULL,
    [MapResultSetEnums]             BIT            CONSTRAINT [DF_Project_MapResultSetEnums] DEFAULT ((0)) NOT NULL,
    [GenerateStaticClass]           BIT            CONSTRAINT [DF_Project_GenerateStaticClass] DEFAULT ((0)) NOT NULL,
    [TreatOutputParamAsInputOutput] BIT            CONSTRAINT [DF_Project_TreatOutputParamAsInputOutput] DEFAULT ((1)) NOT NULL,
    [DefaultDatabase]               NVARCHAR (128) NULL,
    CONSTRAINT [PK_Project] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Project_ClassAccess] FOREIGN KEY ([ClassAccessId]) REFERENCES [Enum].[ClassAccess] ([Id]),
    CONSTRAINT [FK_Project_Language] FOREIGN KEY ([LanguageId]) REFERENCES [Enum].[Language] ([Id])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Project_Name]
    ON [dbo].[Project]([Name] ASC);

